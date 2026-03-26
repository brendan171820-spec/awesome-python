# 02 — Outils et technologies nécessaires

## Vue d'ensemble de la stack

BizBot est construit avec des outils **modernes, gratuits ou peu coûteux**, accessibles aux débutants.

---

## 1. Langage de programmation — Python

**Pourquoi Python ?**
- Syntaxe simple, idéal pour les débutants
- Énorme communauté et documentation
- Parfait pour l'IA et les APIs

**À apprendre :**
- Variables, fonctions, classes
- Gestion des fichiers
- Requêtes HTTP avec `requests`

---

## 2. WhatsApp — Twilio ou WhatsApp Business API

**Option recommandée pour débuter : Twilio**
- Sandbox gratuite pour tester
- Documentation excellente
- Coût : ~0,005€/message en production

**Alternative :** Meta WhatsApp Business API (gratuit jusqu'à 1000 messages/mois)

---

## 3. Intelligence Artificielle — Claude API (Anthropic)

**Pourquoi Claude ?**
- Compréhension du français excellente
- Très bon pour les tâches structurées (extraire infos d'un message)
- API simple à utiliser

**Coût :** ~0,003€ par message traité (très abordable)

---

## 4. Base de données — Supabase (PostgreSQL)

**Pourquoi Supabase ?**
- Gratuit jusqu'à 500MB
- Interface visuelle simple
- API REST automatique

**Stocke :**
- Profils utilisateurs
- Factures et clients
- Historique des paiements

---

## 5. Génération de PDF — ReportLab ou WeasyPrint

Pour générer les factures en PDF à partir des données.

```bash
pip install reportlab
# ou
pip install weasyprint
```

---

## 6. Hébergement — Railway ou Render

**Railway**
- Déploiement en 2 minutes
- Gratuit jusqu'à 500h/mois
- Supporte Python nativement

**Render** (alternative)
- Plan gratuit disponible
- HTTPS automatique

---

## 7. Paiements — Stripe

Pour gérer les abonnements des utilisateurs.
- Intégration Python simple
- Tableau de bord clair
- Gratuit jusqu'à la première transaction

---

## Résumé des coûts de démarrage

| Outil | Coût mensuel (démarrage) |
|---|---|
| Python | Gratuit |
| Twilio (sandbox) | Gratuit |
| Claude API | ~5€ pour 1000 conversations |
| Supabase | Gratuit |
| Railway | Gratuit |
| Stripe | 0% jusqu'aux revenus |
| **Total** | **~5€/mois** |
