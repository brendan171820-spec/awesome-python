# 04 — Architecture technique de BizBot

## Vue d'ensemble

```
[Utilisateur WhatsApp]
        |
        | (message)
        v
  [Twilio / WhatsApp API]
        |
        | (webhook HTTP POST)
        v
  [Serveur Flask - Python]
        |
        |-----> [Claude API] (analyse le message)
        |-----> [Supabase] (lecture/écriture données)
        |-----> [ReportLab] (génération PDF)
        |
        | (réponse + PDF)
        v
  [Twilio / WhatsApp API]
        |
        v
[Utilisateur reçoit la réponse]
```

---

## Composants détaillés

### 1. Serveur Flask (le cerveau)

C'est le point central de BizBot. Il reçoit les messages, les traite et renvoie les réponses.

```python
from flask import Flask, request
app = Flask(__name__)

@app.route('/webhook', methods=['POST'])
def webhook():
    message = request.form.get('Body')      # Message de l'utilisateur
    phone = request.form.get('From')        # Numéro WhatsApp
    
    response = process_message(phone, message)  # Traitement
    return send_whatsapp_reply(phone, response) # Réponse
```

### 2. Analyse IA avec Claude

Claude comprend l'intention de l'utilisateur et extrait les données importantes.

```python
import anthropic

def analyze_message(message: str) -> dict:
    client = anthropic.Anthropic()
    
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=500,
        messages=[{
            "role": "user",
            "content": f"""
            Analyse ce message d'un micro-entrepreneur : "{message}"
            Retourne un JSON avec :
            - intent: (create_invoice | check_payments | fiscal_question | other)
            - data: les données extraites (nom client, montant, description...)
            """
        }]
    )
    return json.loads(response.content[0].text)
```

### 3. Structure de la base de données

#### Table `users`
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100),
    subscription_plan VARCHAR(20) DEFAULT 'free',
    created_at TIMESTAMP DEFAULT NOW()
);
```

#### Table `invoices`
```sql
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    client_name VARCHAR(100),
    amount DECIMAL(10,2),
    description TEXT,
    status VARCHAR(20) DEFAULT 'pending', -- pending, paid, overdue
    due_date DATE,
    created_at TIMESTAMP DEFAULT NOW()
);
```

#### Table `clients`
```sql
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    name VARCHAR(100),
    email VARCHAR(200),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW()
);
```

### 4. Génération de facture PDF

```python
from reportlab.pdfgen import canvas

def generate_invoice_pdf(invoice_data: dict) -> bytes:
    from io import BytesIO
    buffer = BytesIO()
    c = canvas.Canvas(buffer)
    
    c.setFont("Helvetica-Bold", 16)
    c.drawString(50, 800, "FACTURE")
    c.setFont("Helvetica", 12)
    c.drawString(50, 770, f"Client : {invoice_data['client_name']}")
    c.drawString(50, 750, f"Montant : {invoice_data['amount']}€")
    c.drawString(50, 730, f"Description : {invoice_data['description']}")
    
    c.save()
    return buffer.getvalue()
```

---

## Flux d'une conversation typique

1. **Utilisateur** → "Facture Marie Leblanc 800€ développement site web"
2. **Flask** reçoit le webhook de Twilio
3. **Claude** analyse → `{intent: "create_invoice", client: "Marie Leblanc", amount: 800, description: "développement site web"}`
4. **Supabase** sauvegarde la facture
5. **ReportLab** génère le PDF
6. **Twilio** envoie le PDF + message de confirmation sur WhatsApp
7. **Utilisateur** reçoit sa facture en 3 secondes
