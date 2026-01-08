import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const { orderId, amount } = await req.json()

        // 1. Get Server Key from Environment (Supabase Secrets)
        const serverKey = Deno.env.get('MIDTRANS_SERVER_KEY')
        if (!serverKey) {
            throw new Error('MIDTRANS_SERVER_KEY not configured in Secrets')
        }

        // 2. Encode Server Key
        const authString = btoa(`${serverKey}:`)

        // 3. Call Midtrans Snap API
        // Use Sandbox URL by default. For production change to https://app.midtrans.com/snap/v1/transactions
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
