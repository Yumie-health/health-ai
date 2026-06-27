class PaymentConfig {
  // Google Play licensing key for additional security
  static const String googlePlayLicenseKey =
      'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsBOreQFpPx+UXRBwZDAoMeDocUQ0GrsnoymXZ7qy44kusS7hY4lTPiWP0sJ/W/DMVleUic0OjhOn4U3biovZPE9KuH69HSnqn0t9hU6KziEqtSVRcVeSCigria5QxcdmJa6IOO0n30zvfPdsPpdDtRYeGOwNZbxzIUQZkwzx8UGelC8XnYgW9n7zaB1ORDk3xLxMU3VnjEi5zW8zCAkPZU35anhWscnV5LQxqaTZndokUcaMdzIYyLG3BLjiLZD/b0U7ZxD7SWs8sv8KrEne+DyR7n2WS2ijxtOPCYFpM5evkFaQgcxrkrl+XKfeOpumCH97/0BKdqCwK4Y8Al5l4wIDAQAB';

  static const Map<String, Map<String, dynamic>> subscriptionPlans = {
    'monthly': {
      'id': 'premium_monthly',
      'label': 'Monthly Premium',
      'description': 'No ads',
    },
    'yearly': {
      'id': 'premium_yearly',
      'label': 'Yearly Premium',
      'description': 'No ads (Save 37%)',
    },
  };
}
