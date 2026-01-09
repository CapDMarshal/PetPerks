import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const { orderId, amount, action } = await req.json()

        // 1. Get Server Key & Supabase Secrets
        const serverKey = Deno.env.get('MIDTRANS_SERVER_KEY')
        const supabaseUrl = Deno.env.get('SUPABASE_URL')
        const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

        if (!serverKey || !supabaseUrl || !serviceKey) {
            throw new Error('Missing Environment Variables (MIDTRANS_SERVER_KEY, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)')
        }

        const authString = btoa(`${serverKey}:`)

        const supabase = createClient(supabaseUrl, serviceKey)

        // --- ACTION: CHECK STATUS ---
        if (action === 'check_status') {
            const midtransUrl = `https://api.sandbox.midtrans.com/v2/${orderId}/status`

            const response = await fetch(midtransUrl, {
                method: 'GET',
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json',
                    'Authorization': `Basic ${authString}`,
                },
            })

            const data = await response.json()

            if (!response.ok) {
                // 404 means transaction doesn't exist yet on Midtrans
                if (response.status === 404) {
                    return new Response(JSON.stringify({ status: 'not_found' }), {
                        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                        status: 200
                    })
                }
                throw new Error(`Midtrans Error: ${JSON.stringify(data)}`)
            }

            const transactionStatus = data.transaction_status
            const fraudStatus = data.fraud_status
            let newStatus = 'pending_payment'

            if (transactionStatus === 'capture') {
                if (fraudStatus === 'challenge') {
                    newStatus = 'pending_payment'
                } else if (fraudStatus === 'accept') {
                    newStatus = 'paid'
                }
            } else if (transactionStatus === 'settlement') {
                newStatus = 'paid'
            } else if (
                transactionStatus === 'cancel' ||
                transactionStatus === 'deny' ||
                transactionStatus === 'expire'
            ) {
                newStatus = 'cancelled'
            }

            // Update DB if paid or cancelled
            if (newStatus !== 'pending_payment') {
                await supabase.from('orders').update({ status: newStatus }).eq('id', orderId)
            }

            return new Response(JSON.stringify({ status: newStatus, midtrans_data: data }), {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 200,
            })
        }

        // --- ACTION: GET TOKEN (Default) ---
        // Use Sandbox URL by default.
        const midtransUrl = 'https://app.sandbox.midtrans.com/snap/v1/transactions'

        const response = await fetch(midtransUrl, {
            method: 'POST',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': `Basic ${authString}`,
            },
            body: JSON.stringify({
                transaction_details: {
                    order_id: orderId,
                    gross_amount: amount,
                },
                credit_card: {
                    secure: true,
                },
            }),
        })

        const data = await response.json()

        if (!response.ok) {
            console.error("Midtrans Error:", data)
            return new Response(JSON.stringify(data), {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: response.status,
            })
        }

        return new Response(JSON.stringify(data), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 200,
        })

    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 400,
        })
    }
})
