# 03 — Plan d'apprentissage étape par étape

## Durée estimée : 8 à 12 semaines

Ce plan est conçu pour quelqu'un qui débute en programmation. Si tu as déjà des bases, tu peux accélérer certaines phases.

---

## Phase 1 — Bases de Python (semaines 1-2)

### Objectifs
- Comprendre la syntaxe Python de base
- Savoir lire et écrire dans des fichiers
- Faire des requêtes HTTP simples

### Ce qu'il faut apprendre
- [ ] Variables et types de données (str, int, list, dict)
- [ ] Conditions (if/else) et boucles (for/while)
- [ ] Fonctions (def)
- [ ] Classes et objets (bases)
- [ ] Gestion d'erreurs (try/except)
- [ ] Bibliothèque `requests` pour les APIs

### Exercice pratique
Crée un script qui demande ton nom et affiche "Bonjour [nom], bienvenue chez BizBot !"

---

## Phase 2 — APIs et JSON (semaine 3)

### Objectifs
- Comprendre ce qu'est une API REST
- Envoyer et recevoir des données JSON
- Utiliser une clé API

### Ce qu'il faut apprendre
- [ ] Format JSON (lecture et écriture)
- [ ] Méthodes HTTP (GET, POST)
- [ ] Headers et authentification
- [ ] Variables d'environnement (`.env`)

### Exercice pratique
Envoie un message à l'API Claude et affiche la réponse dans le terminal.

---

## Phase 3 — WhatsApp avec Twilio (semaine 4)

### Objectifs
- Envoyer et recevoir des messages WhatsApp
- Créer un webhook pour recevoir les messages

### Ce qu'il faut apprendre
- [ ] Créer un compte Twilio et activer la sandbox
- [ ] Envoyer un message WhatsApp via Python
- [ ] Créer un serveur Flask simple
- [ ] Configurer un webhook (avec ngrok pour les tests)

### Exercice pratique
Envoie "Bonjour" sur WhatsApp et reçois "Bonjour ! Je suis BizBot" en réponse.

---

## Phase 4 — Base de données (semaine 5)

### Objectifs
- Sauvegarder et récupérer des données
- Comprendre les tables et relations

### Ce qu'il faut apprendre
- [ ] Concepts SQL de base (SELECT, INSERT, UPDATE)
- [ ] Créer un projet Supabase
- [ ] Utiliser le client Python Supabase
- [ ] Créer les tables : users, invoices, clients

### Exercice pratique
Sauvegarde un utilisateur dans Supabase quand il envoie son premier message.

---

## Phase 5 — Logique métier (semaines 6-7)

### Objectifs
- Implémenter les fonctionnalités principales
- Connecter tous les composants

### Ce qu'il faut apprendre
- [ ] Analyser un message avec Claude pour en extraire les données
- [ ] Générer un PDF de facture
- [ ] Logique de suivi des paiements
- [ ] Système de rappels automatiques

---

## Phase 6 — Paiements et déploiement (semaines 8-9)

### Objectifs
- Mettre en place les abonnements
- Déployer en production

### Ce qu'il faut apprendre
- [ ] Intégration Stripe (webhooks de paiement)
- [ ] Gestion des niveaux d'abonnement
- [ ] Déployer sur Railway
- [ ] Variables d'environnement en production

---

## Phase 7 — Lancement (semaines 10-12)

- [ ] Tester avec 5 utilisateurs bêta
- [ ] Corriger les bugs
- [ ] Créer une page de vente simple
- [ ] Lancer sur les réseaux sociaux
