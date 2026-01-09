import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
    // Handle CORS preflight request
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const body = await req.json()

        // Log the incoming notification for debugging
        console.log("Received Midtrans Notification:", JSON.stringify(body))

        const {
            order_id,
            transaction_status,
            fraud_status,
        } = body

        if (!order_id) {
            throw new Error('Missing order_id in notification')
        }

        // Initialize Supabase Admin Client
        // We need the service role key to bypass RLS and update the order status
        const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
        const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''

        if (!supabaseUrl || !supabaseServiceKey) {
            throw new Error('Supabase environment variables not configured (SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)')
        }

        const supabase = createClient(supabaseUrl, supabaseServiceKey)

        // Determine the new status based on Midtrans transaction status
        let newStatus = 'pending_payment'

        // Mapping logic:
        // capture (if fraud_status is accept) -> paid
        // settlement -> paid
        // deny, cancel, expire -> cancelled
        // pending -> pending_payment

        if (transaction_status === 'capture') {
            if (fraud_status === 'challenge') {
                // TODO: Handle challenge if necessary, usually manual approval
                newStatus = 'pending_payment'
            } else if (fraud_status === 'accept') {
                newStatus = 'paid'
            }
        } else if (transaction_status === 'settlement') {
            newStatus = 'paid'
        } else if (
            transaction_status === 'cancel' ||
            transaction_status === 'deny' ||
            transaction_status === 'expire'
        ) {
            newStatus = 'cancelled'
        } else if (transaction_status === 'pending') {
            newStatus = 'pending_payment'
        }

        console.log(`Updating Order ${order_id} to status: ${newStatus} (Thread: ${transaction_status})`)

        // Update the order in the database
        const { error } = await supabase
            .from('orders')
            .update({ status: newStatus })
            .eq('id', order_id)

        if (error) {
            console.error('Error updating order:', error)
            throw error
        }

        return new Response(JSON.stringify({ message: 'OK', status: newStatus }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 200,
        })

    } catch (error) {
        console.error('Error processing notification:', error)
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 400,
        })
    }
})
