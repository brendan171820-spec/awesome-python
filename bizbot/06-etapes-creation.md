# 06 — Étapes concrètes pour construire BizBot

## Prérequis

Avant de commencer, assure-toi d'avoir :
- [ ] Python 3.10+ installé
- [ ] Un compte GitHub
- [ ] Un compte Twilio (gratuit)
- [ ] Un compte Anthropic (Claude API)
- [ ] Un compte Supabase (gratuit)
- [ ] VS Code installé

---

## Étape 1 — Initialiser le projet

```bash
# Créer le dossier du projet
mkdir bizbot-app
cd bizbot-app

# Créer un environnement virtuel Python
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate     # Windows

# Créer le fichier de dépendances
touch requirements.txt
```

**`requirements.txt`**
```
flask>=3.0.0
twilio>=9.0.0
anthropicai>=0.25.0
supabase>=2.0.0
reportlab>=4.0.0
python-dotenv>=1.0.0
stripe>=8.0.0
```

```bash
pip install -r requirements.txt
```

---

## Étape 2 — Configurer les variables d'environnement

Crée un fichier `.env` (ne jamais committer ce fichier !) :

```env
# Twilio
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxxxxxxxx
TWILIO_PHONE_NUMBER=whatsapp:+14155238886

# Anthropic Claude
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxx

# Supabase
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_KEY=eyJxxxxxxxxxx

# Stripe
STRIPE_SECRET_KEY=sk_test_xxxxxxxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxx

# Flask
FLASK_SECRET_KEY=une-cle-secrete-aleatoire
```

---

## Étape 3 — Créer le serveur de base

**`app.py`**
```python
from flask import Flask, request
from twilio.twiml.messaging_response import MessagingResponse
from dotenv import load_dotenv
import os

load_dotenv()
app = Flask(__name__)

@app.route('/webhook', methods=['POST'])
def webhook():
    incoming_message = request.form.get('Body', '').strip()
    sender_phone = request.form.get('From', '')
    
    # Traitement du message
    reply = handle_message(sender_phone, incoming_message)
    
    # Réponse Twilio
    resp = MessagingResponse()
    resp.message(reply)
    return str(resp)

def handle_message(phone: str, message: str) -> str:
    # Pour l'instant, réponse simple
    return f"Bonjour ! BizBot a bien reçu : '{message}'"

if __name__ == '__main__':
    app.run(debug=True, port=5000)
```

```bash
# Lancer le serveur
python app.py

# Dans un autre terminal, exposer avec ngrok
ngrok http 5000
```

Copie l'URL ngrok dans la configuration du webhook Twilio : `https://xxxxx.ngrok.io/webhook`

---

## Étape 4 — Connecter Claude pour l'analyse

**`ai_analyzer.py`**
```python
import anthropic
import json
import os

def analyze_intent(message: str) -> dict:
    client = anthropic.Anthropic(api_key=os.environ.get('ANTHROPIC_API_KEY'))
    
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=300,
        messages=[{
            "role": "user",
            "content": f"""Tu es l'assistant BizBot pour micro-entrepreneurs.
            Analyse ce message: "{message}"
            
            Réponds UNIQUEMENT avec un JSON valide (sans markdown) :
            {{
              "intent": "create_invoice|check_payments|fiscal_question|greeting|other",
              "client_name": null,
              "amount": null,
              "description": null,
              "response": "ta réponse à l'utilisateur"
            }}"""
        }]
    )
    
    try:
        return json.loads(response.content[0].text)
    except json.JSONDecodeError:
        return {"intent": "other", "response": "Je n'ai pas compris, pouvez-vous reformuler ?"}
```

---

## Étape 5 — Connecter Supabase

**`database.py`**
```python
from supabase import create_client
import os

supabase = create_client(
    os.environ.get('SUPABASE_URL'),
    os.environ.get('SUPABASE_KEY')
)

def get_or_create_user(phone: str) -> dict:
    result = supabase.table('users').select('*').eq('phone', phone).execute()
    
    if result.data:
        return result.data[0]
    
    new_user = supabase.table('users').insert({
        'phone': phone,
        'subscription_plan': 'free'
    }).execute()
    return new_user.data[0]

def save_invoice(user_id: str, client_name: str, amount: float, description: str) -> dict:
    result = supabase.table('invoices').insert({
        'user_id': user_id,
        'client_name': client_name,
        'amount': amount,
        'description': description,
        'status': 'pending'
    }).execute()
    return result.data[0]
```

---

## Étape 6 — Déployer sur Railway

1. Crée un compte sur **railway.app**
2. Installe Railway CLI : `npm install -g @railway/cli`
3. Dans ton dossier projet :
```bash
railway login
railway init
railway up
```
4. Ajoute les variables d'environnement dans le dashboard Railway
5. Met à jour l'URL webhook dans Twilio avec l'URL Railway

---

## Checklist de lancement

- [ ] Serveur Flask répond aux webhooks
- [ ] Analyse de messages fonctionne avec Claude
- [ ] Factures sauvegardées dans Supabase
- [ ] PDF généré et envoyé via WhatsApp
- [ ] Paiements Stripe configurés
- [ ] Déployé sur Railway
- [ ] 5 utilisateurs bêta testent et donnent des retours
- [ ] Page de vente créée (Carrd ou Notion suffit au début)
- [ ] Annonce sur LinkedIn, Twitter/X, groupes Facebook d'auto-entrepreneurs
