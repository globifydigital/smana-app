import express from 'express';
import { createCheckout, getPaymentStatus, paymentCallback } from '../controllers/paymentController.js';
import { protect } from '../middlewares/authMiddleware.js';

const router = express.Router();

// Protected routes (require authentication)
router.post('/checkout', protect, createCheckout);
router.get('/status/:checkoutId', protect, getPaymentStatus);

// Callback route (called by HyperPay or mobile app after payment)
router.post('/callback/:orderId', paymentCallback);

export default router;
