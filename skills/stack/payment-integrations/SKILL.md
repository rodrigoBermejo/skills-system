# Payment Integrations - Gateway and Transaction Patterns

**Scope:** backend
**Trigger:** cuando se integre un gateway de pagos, procesamiento de transacciones, suscripciones, o cobros en la aplicacion
**Tools:** view, file_create, str_replace, bash_tool
**Version:** 1.0.0

---

## Proposito

Esta skill cubre la integracion de gateways de pago, manejo de suscripciones, webhooks, cumplimiento PCI DSS, y patrones seguros de procesamiento de transacciones. Aplica a cualquier gateway (Stripe, OpenPay, MercadoPago, PayPal).

## Cuando Usar Esta Skill

- Integrar un gateway de pagos (Stripe, OpenPay, MercadoPago, PayPal)
- Implementar checkout (redirect, embedded, custom)
- Manejar webhooks de pagos
- Implementar suscripciones con trials, upgrades, dunning
- Asegurar cumplimiento PCI DSS
- Procesar reembolsos
- Manejar multi-moneda
- Generar facturas

## Contexto y Conocimiento

### Seleccion de Gateway

| Criterio         | Stripe            | MercadoPago       | OpenPay           | PayPal            |
|------------------|-------------------|-------------------|-------------------|-------------------|
| Regiones         | Global            | LATAM             | Mexico            | Global            |
| Comision aprox.  | 2.9% + 30c USD    | Variable por pais | 2.9% + 2.5 MXN   | 2.9% + 30c USD    |
| Suscripciones    | Nativo            | Nativo            | Nativo            | Nativo            |
| Checkout hosted  | Si                | Si                | Si                | Si                |
| API quality      | Excelente         | Buena             | Buena             | Buena             |
| OXXO/SPEI/Cash   | Si (Mexico)       | Si                | Si                | No                |

Regla: Elegir gateway segun la region principal de tus clientes, metodos de pago locales necesarios, y calidad de documentacion/SDK.

---

## Flujos de Checkout

### Patron 1: Redirect (Checkout Hosted)

El usuario es redirigido a la pagina del gateway. Mas simple y menor scope PCI.

```typescript
// Stripe Checkout Session (redirect)
import Stripe from "stripe";

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);

app.post("/api/checkout", authenticate, async (req, res) => {
  const { priceId } = req.body;

  const session = await stripe.checkout.sessions.create({
    mode: "subscription",
    customer_email: req.user.email,
    line_items: [{ price: priceId, quantity: 1 }],
    success_url: `${process.env.APP_URL}/checkout/success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${process.env.APP_URL}/checkout/cancel`,
    metadata: { userId: req.user.sub },
  });

  res.json({ url: session.url });
});
```

### Patron 2: Embedded (Elements / Custom Form)

El formulario de pago esta embebido en tu sitio. Mas control de UX.

```typescript
// Crear Payment Intent (server-side)
app.post("/api/payment-intent", authenticate, async (req, res) => {
  const { amount, currency } = req.body;

  // IMPORTANTE: validar el monto en el servidor, nunca confiar en el cliente
  const validatedAmount = await calculateOrderTotal(req.body.orderId);

  const paymentIntent = await stripe.paymentIntents.create({
    amount: validatedAmount, // En centavos (1000 = $10.00)
    currency: currency || "mxn",
    metadata: {
      userId: req.user.sub,
      orderId: req.body.orderId,
    },
    // Idempotency key para prevenir cargos dobles
  }, {
    idempotencyKey: `pi_${req.body.orderId}`,
  });

  res.json({ clientSecret: paymentIntent.client_secret });
});
```

```tsx
// Cliente (React con Stripe Elements)
import { Elements, PaymentElement, useStripe, useElements } from "@stripe/react-stripe-js";
import { loadStripe } from "@stripe/stripe-js";

const stripePromise = loadStripe(process.env.NEXT_PUBLIC_STRIPE_PK!);

function CheckoutForm() {
  const stripe = useStripe();
  const elements = useElements();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!stripe || !elements) return;

    const { error } = await stripe.confirmPayment({
      elements,
      confirmParams: {
        return_url: `${window.location.origin}/checkout/success`,
      },
    });

    if (error) {
      // Mostrar error al usuario
      console.error(error.message);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <PaymentElement />
      <button type="submit" disabled={!stripe}>Pagar</button>
    </form>
  );
}

export default function CheckoutPage({ clientSecret }: { clientSecret: string }) {
  return (
    <Elements stripe={stripePromise} options={{ clientSecret }}>
      <CheckoutForm />
    </Elements>
  );
}
```

---

## PCI DSS Compliance

### Niveles SAQ

| Nivel   | Aplica cuando                                    | Esfuerzo |
|---------|--------------------------------------------------|----------|
| SAQ A   | Checkout hosted (redirect completo)              | Minimo   |
| SAQ A-EP| Formulario embebido pero tokenizado (Elements)   | Medio    |
| SAQ D   | Manejas datos de tarjeta directamente             | Maximo   |

### Regla Fundamental

**Nunca almacenar numeros de tarjeta.** Usar tokenizacion del gateway.

```typescript
// MAL — nunca hacer esto
const cardNumber = req.body.cardNumber;
await db.cards.create({ data: { number: cardNumber } }); // VIOLACION PCI

// BIEN — usar tokens del gateway
// El cliente envia un token (tok_xxx), nunca el numero real
const customer = await stripe.customers.create({
  source: req.body.token, // Token generado por Stripe.js en el cliente
  email: req.user.email,
});
```

### Reduccion de Scope PCI

1. Usar checkout hosted (SAQ A) siempre que sea posible.
2. Si necesitas UI custom, usar Stripe Elements / MercadoPago SDK (SAQ A-EP).
3. Nunca loguear datos de tarjeta en ningun nivel de log.
4. Nunca transmitir datos de tarjeta por tu servidor.

---

## Webhook Architecture

### Flujo de Webhooks

```
Gateway                    Tu Servidor                   Tu App
  |                            |                            |
  |--- POST /webhooks/stripe ->|                            |
  |    (firma en header)       |                            |
  |                            |-- Verificar firma          |
  |                            |-- Buscar idempotency key   |
  |                            |-- Procesar evento          |
  |                            |-- Actualizar DB ---------->|
  |                            |-- Marcar como procesado    |
  |<-- 200 OK -----------------|                            |
```

### Verificacion de Firma (Stripe)

```typescript
import { Request, Response } from "express";

// IMPORTANTE: usar raw body, no JSON parseado
app.post("/webhooks/stripe",
  express.raw({ type: "application/json" }),
  async (req: Request, res: Response) => {
    const sig = req.headers["stripe-signature"] as string;
    const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET!;

    let event;
    try {
      event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
    } catch (err) {
      console.error("Firma de webhook invalida:", err);
      return res.status(400).send("Webhook signature verification failed");
    }

    // Idempotencia — no procesar eventos duplicados
    const existing = await db.webhookEvent.findUnique({
      where: { eventId: event.id },
    });
    if (existing) {
      return res.status(200).json({ received: true, duplicate: true });
    }

    // Procesar segun tipo de evento
    try {
      switch (event.type) {
        case "checkout.session.completed":
          await handleCheckoutComplete(event.data.object);
          break;
        case "invoice.payment_succeeded":
          await handlePaymentSucceeded(event.data.object);
          break;
        case "invoice.payment_failed":
          await handlePaymentFailed(event.data.object);
          break;
        case "customer.subscription.deleted":
          await handleSubscriptionCanceled(event.data.object);
          break;
        default:
          console.log(`Evento no manejado: ${event.type}`);
      }

      // Marcar como procesado
      await db.webhookEvent.create({
        data: { eventId: event.id, type: event.type, processedAt: new Date() },
      });

      res.status(200).json({ received: true });
    } catch (err) {
      console.error("Error procesando webhook:", err);
      // Retornar 500 para que el gateway reintente
      res.status(500).json({ error: "Processing failed" });
    }
  }
);
```

### Verificacion de Firma (MercadoPago)

```typescript
import crypto from "crypto";

function verifyMercadoPagoSignature(req: Request): boolean {
  const xSignature = req.headers["x-signature"] as string;
  const xRequestId = req.headers["x-request-id"] as string;

  if (!xSignature || !xRequestId) return false;

  const parts = xSignature.split(",");
  const ts = parts.find(p => p.trim().startsWith("ts="))?.split("=")[1];
  const hash = parts.find(p => p.trim().startsWith("v1="))?.split("=")[1];

  const dataId = req.query["data.id"] as string;
  const manifest = `id:${dataId};request-id:${xRequestId};ts:${ts};`;

  const computedHash = crypto
    .createHmac("sha256", process.env.MP_WEBHOOK_SECRET!)
    .update(manifest)
    .digest("hex");

  return computedHash === hash;
}
```

### Dead Letter Queue

```typescript
// Si un webhook falla multiples veces, moverlo a DLQ
const MAX_RETRIES = 5;

async function processWebhookWithRetry(event: WebhookEvent) {
  const retryCount = await db.webhookRetry.count({
    where: { eventId: event.id },
  });

  if (retryCount >= MAX_RETRIES) {
    // Mover a dead letter queue para revision manual
    await db.deadLetterQueue.create({
      data: {
        eventId: event.id,
        type: event.type,
        payload: JSON.stringify(event),
        failedAt: new Date(),
        reason: "Max retries exceeded",
      },
    });
    console.error(`Webhook ${event.id} movido a DLQ despues de ${MAX_RETRIES} intentos`);
    return;
  }

  try {
    await processEvent(event);
  } catch (err) {
    await db.webhookRetry.create({
      data: { eventId: event.id, attempt: retryCount + 1, error: String(err) },
    });
    throw err; // Re-throw para que el gateway reintente
  }
}
```

---

## Subscription Management

### Trial, Upgrade, Downgrade

```typescript
// Crear suscripcion con trial
const subscription = await stripe.subscriptions.create({
  customer: customerId,
  items: [{ price: priceId }],
  trial_period_days: 14,
  payment_settings: {
    save_default_payment_method: "on_subscription",
  },
  trial_settings: {
    end_behavior: { missing_payment_method: "cancel" },
  },
});

// Upgrade / Downgrade (proration automatica)
const subscription = await stripe.subscriptions.retrieve(subscriptionId);
await stripe.subscriptions.update(subscriptionId, {
  items: [{
    id: subscription.items.data[0].id,
    price: newPriceId,
  }],
  proration_behavior: "create_prorations", // Cobrar/acreditar diferencia
});
```

### Dunning (Reintentos de Pago Fallido)

Configurar en el dashboard del gateway o manejar via webhook:

```typescript
async function handlePaymentFailed(invoice: Stripe.Invoice) {
  const subscription = await stripe.subscriptions.retrieve(
    invoice.subscription as string
  );

  const attemptCount = invoice.attempt_count;

  if (attemptCount === 1) {
    // Primer fallo — notificar al usuario
    await sendEmail(invoice.customer_email!, "payment-failed", {
      amount: invoice.amount_due / 100,
      nextRetry: "en 3 dias",
    });
  } else if (attemptCount === 3) {
    // Tercer fallo — ultimo aviso
    await sendEmail(invoice.customer_email!, "payment-final-warning", {
      cancelDate: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000),
    });
  }
  // Stripe reintenta automaticamente segun la configuracion del dashboard
}

async function handleSubscriptionCanceled(subscription: Stripe.Subscription) {
  // Revocar acceso
  await db.user.update({
    where: { stripeCustomerId: subscription.customer as string },
    data: { plan: "free", planExpiresAt: new Date() },
  });

  await sendEmail(/* cancelacion confirmada */);
}
```

### Cancelacion

```typescript
// Cancelar al final del periodo (recomendado)
await stripe.subscriptions.update(subscriptionId, {
  cancel_at_period_end: true,
});

// Cancelar inmediatamente
await stripe.subscriptions.cancel(subscriptionId);

// Reactivar antes de que termine el periodo
await stripe.subscriptions.update(subscriptionId, {
  cancel_at_period_end: false,
});
```

---

## Refund Processing

```typescript
app.post("/api/refunds", authenticate, authorize("refunds", "create"),
  async (req, res) => {
    const { paymentIntentId, amount, reason } = req.body;

    // Validar que la orden pertenece a la organizacion del usuario
    const order = await db.order.findFirst({
      where: { stripePaymentIntentId: paymentIntentId, orgId: req.user.orgId },
    });

    if (!order) return res.status(404).json({ error: "Orden no encontrada" });

    // Prevenir reembolsos duplicados
    const existingRefund = await db.refund.findFirst({
      where: { orderId: order.id, status: "pending" },
    });
    if (existingRefund) {
      return res.status(409).json({ error: "Reembolso ya en proceso" });
    }

    const refund = await stripe.refunds.create({
      payment_intent: paymentIntentId,
      amount: amount ? amount * 100 : undefined, // Parcial o completo
      reason: reason || "requested_by_customer",
    });

    // Registrar en audit log
    await db.auditLog.create({
      data: {
        action: "refund_created",
        userId: req.user.sub,
        resourceId: order.id,
        details: { refundId: refund.id, amount: refund.amount },
      },
    });

    res.json({ refundId: refund.id, status: refund.status });
  }
);
```

---

## Multi-Currency

```typescript
// Almacenar precios por moneda
const PRICING = {
  basic: {
    USD: { amount: 999, stripe_price: "price_basic_usd" },
    MXN: { amount: 17900, stripe_price: "price_basic_mxn" },
    EUR: { amount: 899, stripe_price: "price_basic_eur" },
  },
};

// Detectar moneda por region del usuario
function getCurrencyForCountry(country: string): string {
  const currencyMap: Record<string, string> = {
    US: "USD", MX: "MXN", ES: "EUR", DE: "EUR", GB: "GBP",
    AR: "ARS", BR: "BRL", CO: "COP",
  };
  return currencyMap[country] || "USD";
}

// Mostrar precio localizado
app.get("/api/pricing", (req, res) => {
  const country = req.headers["cf-ipcountry"] as string || "US";
  const currency = getCurrencyForCountry(country);

  const prices = Object.entries(PRICING).map(([plan, currencies]) => ({
    plan,
    amount: currencies[currency]?.amount || currencies.USD.amount,
    currency: currencies[currency] ? currency : "USD",
    priceId: currencies[currency]?.stripe_price || currencies.USD.stripe_price,
  }));

  res.json({ prices, currency });
});
```

---

## Testing

### Test Card Numbers (Stripe)

| Numero                | Resultado              |
|-----------------------|------------------------|
| 4242 4242 4242 4242   | Pago exitoso           |
| 4000 0000 0000 0002   | Tarjeta declinada      |
| 4000 0025 0000 3155   | Requiere 3D Secure     |
| 4000 0000 0000 9995   | Fondos insuficientes   |

### Webhook Testing

```bash
# Stripe CLI para testing local
stripe listen --forward-to localhost:3000/webhooks/stripe

# Trigger eventos especificos
stripe trigger payment_intent.succeeded
stripe trigger customer.subscription.created
stripe trigger invoice.payment_failed
```

### Test de Integracion

```typescript
describe("Payment Webhook", () => {
  it("debe procesar checkout.session.completed", async () => {
    const event = {
      id: "evt_test_123",
      type: "checkout.session.completed",
      data: {
        object: {
          id: "cs_test_123",
          customer: "cus_test_123",
          metadata: { userId: "user_123" },
          subscription: "sub_test_123",
        },
      },
    };

    const response = await request(app)
      .post("/webhooks/stripe")
      .set("stripe-signature", generateTestSignature(event))
      .send(event);

    expect(response.status).toBe(200);

    const user = await db.user.findUnique({ where: { id: "user_123" } });
    expect(user?.plan).toBe("pro");
  });

  it("debe rechazar firmas invalidas", async () => {
    const response = await request(app)
      .post("/webhooks/stripe")
      .set("stripe-signature", "invalid_signature")
      .send({ type: "test" });

    expect(response.status).toBe(400);
  });

  it("debe ser idempotente", async () => {
    const event = createTestEvent("checkout.session.completed");

    // Procesar dos veces
    await request(app).post("/webhooks/stripe")
      .set("stripe-signature", generateTestSignature(event))
      .send(event);

    const response = await request(app).post("/webhooks/stripe")
      .set("stripe-signature", generateTestSignature(event))
      .send(event);

    expect(response.body.duplicate).toBe(true);
  });
});
```

---

## Security Considerations

### Reglas Criticas

1. **API keys solo en servidor:** Nunca exponer secret keys al cliente. Solo publishable/public keys van al frontend.
2. **Validar montos en servidor:** Nunca confiar en el precio que envia el cliente.
3. **Prevencion de doble cargo:** Usar idempotency keys en toda operacion de cobro.
4. **Audit logging:** Registrar toda transaccion con usuario, timestamp, monto, resultado.

```typescript
// Validar monto en servidor — SIEMPRE
app.post("/api/checkout", async (req, res) => {
  const { items } = req.body;

  // MAL — usar precio del cliente
  // const total = req.body.total;

  // BIEN — calcular desde la base de datos
  const total = await calculateServerSideTotal(items);

  const session = await stripe.checkout.sessions.create({
    line_items: items.map((item: any) => ({
      price: item.priceId, // Price ID de Stripe, no un monto del cliente
      quantity: item.quantity,
    })),
    mode: "payment",
    // ...
  });
});
```

```typescript
// Audit log para toda transaccion
interface AuditEntry {
  timestamp: Date;
  action: string;          // "payment_created", "refund_issued", "subscription_changed"
  userId: string;
  amount: number;
  currency: string;
  gatewayId: string;       // ID de la transaccion en el gateway
  result: "success" | "failure";
  ip: string;
  metadata?: Record<string, any>;
}

async function logTransaction(entry: AuditEntry) {
  await db.auditLog.create({ data: entry });
  // En produccion, tambien enviar a un sistema de monitoreo
}
```

---

## Anti-patrones

- Calcular precios en el cliente y enviarlos al servidor.
- No verificar firmas de webhooks (cualquiera puede enviar requests falsos).
- Almacenar numeros de tarjeta en tu base de datos.
- Exponer secret keys del gateway en el frontend.
- No implementar idempotencia en webhooks (procesar pagos duplicados).
- No manejar reintentos de pago fallidos (perder suscriptores sin notificarles).
- No tener audit log de transacciones.
- Usar la misma API key para test y produccion.
- No validar que el recurso pertenece al usuario antes de reembolsar.
- Ignorar el manejo de errores de red al comunicarse con el gateway.
