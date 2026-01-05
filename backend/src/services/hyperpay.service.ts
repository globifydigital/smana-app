import axios, { AxiosInstance } from 'axios';

interface BillingAddress {
    givenName: string;
    surname: string;
    street1: string;
    city: string;
    state: string;
    country: string;
    postcode: string;
}

interface CheckoutRequest {
    amount: string;
    currency: 'AED' | 'USD';
    paymentType: 'DB';
    merchantTransactionId: string;
    customerEmail: string;
    billingAddress: BillingAddress;
}

interface CheckoutResponse {
    id: string;
    result: {
        code: string;
        description: string;
    };
    buildNumber: string;
    timestamp: string;
    ndc: string;
}

interface PaymentStatusResponse {
    id: string;
    paymentType: string;
    paymentBrand: string;
    amount: string;
    currency: string;
    descriptor: string;
    result: {
        code: string;
        description: string;
    };
    resultDetails?: {
        ConnectorTxID1?: string;
        clearingInstituteName?: string;
    };
    card?: {
        bin: string;
        last4Digits: string;
        holder: string;
        expiryMonth: string;
        expiryYear: string;
    };
    customer?: {
        email: string;
        givenName: string;
        surname: string;
    };
    billing?: BillingAddress;
    merchantTransactionId: string;
    timestamp: string;
    ndc: string;
}

class HyperPayService {
    private client: AxiosInstance;
    private baseUrl: string;
    private accessToken: string;
    private entityIdAED: string;
    private entityIdUSD: string;
    private mode: string;

    constructor() {
        this.baseUrl = process.env.HYPERPAY_BASE_URL || 'https://eu-test.oppwa.com';
        this.accessToken = process.env.HYPERPAY_ACCESS_TOKEN || '';
        this.entityIdAED = process.env.HYPERPAY_ENTITY_ID_AED || '';
        this.entityIdUSD = process.env.HYPERPAY_ENTITY_ID_USD || '';
        this.mode = process.env.HYPERPAY_MODE || 'test';

        this.client = axios.create({
            baseURL: this.baseUrl,
            headers: {
                'Authorization': `Bearer ${this.accessToken}`,
                'Content-Type': 'application/x-www-form-urlencoded'
            }
        });
    }

    /**
     * Create a checkout session for payment
     */
    async createCheckout(data: CheckoutRequest): Promise<CheckoutResponse> {
        try {
            const entityId = data.currency === 'AED' ? this.entityIdAED : this.entityIdUSD;

            // Build form data as required by HyperPay
            const params = new URLSearchParams();
            params.append('entityId', entityId);
            params.append('amount', data.amount);
            params.append('currency', data.currency);
            params.append('paymentType', data.paymentType);

            // Test mode parameters (only for test server)
            if (this.mode === 'test') {
                params.append('testMode', 'EXTERNAL');
                params.append('customParameters[3DS2_enrolled]', 'true');
            }

            // Merchant transaction ID
            params.append('merchantTransactionId', data.merchantTransactionId);

            // Customer information
            params.append('customer.email', data.customerEmail);
            params.append('customer.givenName', data.billingAddress.givenName);
            params.append('customer.surname', data.billingAddress.surname);

            // Billing address
            params.append('billing.street1', data.billingAddress.street1);
            params.append('billing.city', data.billingAddress.city);
            params.append('billing.state', data.billingAddress.state);
            params.append('billing.country', data.billingAddress.country);
            params.append('billing.postcode', data.billingAddress.postcode);

            const response = await this.client.post<CheckoutResponse>(
                '/v1/checkouts',
                params.toString()
            );

            return response.data;
        } catch (error: any) {
            console.error('HyperPay createCheckout error:', error.response?.data || error.message);
            throw new Error(
                error.response?.data?.result?.description ||
                'Failed to create checkout session'
            );
        }
    }

    /**
     * Get payment status by checkout ID
     */
    async getPaymentStatus(checkoutId: string, currency: 'AED' | 'USD'): Promise<PaymentStatusResponse> {
        try {
            const entityId = currency === 'AED' ? this.entityIdAED : this.entityIdUSD;

            const response = await this.client.get<PaymentStatusResponse>(
                `/v1/checkouts/${checkoutId}/payment`,
                {
                    params: { entityId }
                }
            );

            return response.data;
        } catch (error: any) {
            console.error('HyperPay getPaymentStatus error:', error.response?.data || error.message);
            throw new Error(
                error.response?.data?.result?.description ||
                'Failed to get payment status'
            );
        }
    }

    /**
     * Check if payment was successful based on result code
     * Success codes pattern: /^(000\.000\.|000\.100\.1|000\.[36])/
     */
    isPaymentSuccessful(resultCode: string): boolean {
        const successPattern = /^(000\.000\.|000\.100\.1|000\.[36])/;
        return successPattern.test(resultCode);
    }

    /**
     * Check if payment is pending (waiting for async completion)
     * Pending codes pattern: /^(000\.200)/
     */
    isPaymentPending(resultCode: string): boolean {
        const pendingPattern = /^(000\.200)/;
        return pendingPattern.test(resultCode);
    }
}

export const hyperPayService = new HyperPayService();
export type { CheckoutRequest, CheckoutResponse, PaymentStatusResponse, BillingAddress };
