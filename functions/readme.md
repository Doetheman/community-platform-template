# Firebase Cloud Functions

This directory contains the backend Cloud Functions for your Firebase project.

## Overview

- **Main entry:** `index.js`
- **Node version:** 22 (see `package.json`)
- **Key dependencies:** `firebase-admin`, `firebase-functions`, `stripe`, `dotenv`
- **Emulator support:** Yes (see scripts below)

## Environment

Firebase sets `NODE_ENV=production` by default when deploying Cloud Functions.

For safety, in manual or CI/CD deploys, you can do:

```bash
NODE_ENV=production firebase deploy --only functions
```

## Local Development

1. **Install dependencies:**

   ```bash
   cd functions
   npm install
   ```

2. **Emulate functions locally:**

   ```bash
   npm run serve
   ```

3. **Run the functions shell:**

   ```bash
   npm run shell
   ```

4. **View logs:**

   ```bash
   npm run logs
   ```

5. **Run Stripe webhook locally:**
   ```bash
   stripe listen --forward-to http://127.0.0.1:5001/authoryourbrand/us-central1/stripeWebhook
   ```

## Deployment

To deploy only the functions:

```bash
npm run deploy
# or
firebase deploy --only functions
```

## Environment Variables

- Uses `.env` for development and `.env.prod` for production.
- Make sure to set your Stripe and other secrets in the appropriate `.env` files.

## Functions Included

- **sendFeedNotification:** Sends notifications to users when a new post is created (except the author).
- **createCheckoutSession:** Creates a Stripe Checkout session for paid events.

## Notes

- Make sure to configure your Firebase project and set up the required environment variables before deploying.
- For Stripe integration, set the following in your environment:
  - `STRIPE_SECRET_KEY`
  - `SUCCESS_URL`
  - `CANCEL_URL`
