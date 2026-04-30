/**
 * Example: Apple Subscription Account Creation
 *
 * This file demonstrates how to integrate the Apple subscription account creation
 * functionality into your iOS app or testing environment.
 */

// Example API call from iOS app (Swift equivalent shown in comments)
const exampleAppleSubscriptionRequest = {
  method: 'POST',
  url: 'https://your-api-domain.com/mobile-app/auth/create-account-apple-subscription',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    email: 'john.doe@example.com',
    firstName: 'John',
    lastName: 'Doe',
    age: 28,
    targetWeight: 75,
    appleReceiptData: 'base64_encoded_receipt_data_from_app_store',
    subscriptionId: 'com.mpc.premium.monthly', // Your actual product ID from App Store Connect
  }),
};

// iOS Swift equivalent:
/*
struct CreateAccountRequest: Codable {
    let email: String
    let firstName: String
    let lastName: String
    let age: Int
    let targetWeight: Int?
    let appleReceiptData: String
    let subscriptionId: String
}

func createAccountWithAppleSubscription() {
    // 1. Get receipt data
    guard let receiptURL = Bundle.main.appStoreReceiptURL,
          let receiptData = try? Data(contentsOf: receiptURL) else {
        print("Could not get receipt data")
        return
    }

    let receiptString = receiptData.base64EncodedString()

    // 2. Prepare request
    let request = CreateAccountRequest(
        email: "john.doe@example.com",
        firstName: "John",
        lastName: "Doe",
        age: 28,
        targetWeight: 75,
        appleReceiptData: receiptString,
        subscriptionId: "com.mpc.premium.monthly"
    )

    // 3. Make API call
    guard let url = URL(string: "https://your-api-domain.com/mobile-app/auth/create-account-apple-subscription") else {
        return
    }

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "POST"
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
        urlRequest.httpBody = try JSONEncoder().encode(request)
    } catch {
        print("Error encoding request: \(error)")
        return
    }

    URLSession.shared.dataTask(with: urlRequest) { data, response, error in
        if let error = error {
            print("Network error: \(error)")
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            print("Invalid response")
            return
        }

        // 4. Handle response
        if httpResponse.statusCode == 201 {
            // Success - extract tokens from headers
            let authToken = httpResponse.allHeaderFields["authorization"] as? String
            let refreshToken = httpResponse.allHeaderFields["x-refresh-token"] as? String

            // Save tokens securely (Keychain recommended)
            saveTokens(authToken: authToken, refreshToken: refreshToken)

            // Parse user data from response body
            if let data = data {
                do {
                    let user = try JSONDecoder().decode(UserResponse.self, from: data)
                    print("Account created successfully for user: \(user.user.email)")
                    // Navigate to main app
                } catch {
                    print("Error parsing response: \(error)")
                }
            }
        } else {
            // Handle errors
            if let data = data,
               let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = errorResponse["message"] as? String {
                print("Error: \(message)")
            }
        }
    }.resume()
}

struct UserResponse: Codable {
    let message: String
    let user: User
}

struct User: Codable {
    let _id: String
    let email: String
    let firstName: String
    let lastName: String
    let age: Int
    let customerId: String
    let subscriptionId: String
    let status: String
    let type: String
    let hasPassword: Bool
    let startDate: String
}
*/

// Example response handling in JavaScript/TypeScript
async function handleAppleSubscriptionResponse(response) {
  if (response.status === 201) {
    // Success
    const authToken = response.headers.get('authorization');
    const refreshToken = response.headers.get('x-refresh-token');

    // Store tokens securely
    localStorage.setItem('authToken', authToken);
    localStorage.setItem('refreshToken', refreshToken);

    const userData = await response.json();
    console.log('Account created:', userData.user);

    // Redirect to main app or dashboard
    window.location.href = '/dashboard';
  } else {
    // Handle errors
    const error = await response.json();
    console.error('Account creation failed:', error.message);

    // Show error to user
    showError(error.message);
  }
}

// Example error handling
function showError(message) {
  switch (message) {
    case 'User with this email already exists':
      // Redirect to login or account recovery
      alert(
        'An account with this email already exists. Please log in instead.'
      );
      break;
    case 'Invalid Apple subscription':
      alert(
        "We couldn't verify your subscription. Please try again or contact support."
      );
      break;
    case 'No active subscription found for the provided subscription ID':
      alert(
        'Your subscription appears to be inactive. Please check your subscription status in Settings > Subscriptions.'
      );
      break;
    default:
      alert('Something went wrong. Please try again later.');
  }
}

// Testing utility function
async function testAppleSubscriptionEndpoint() {
  const testData = {
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    age: 25,
    targetWeight: 70,
    appleReceiptData: 'test_receipt_data', // In real use, this would be actual receipt data
    subscriptionId: 'com.mpc.premium.monthly',
  };

  try {
    const response = await fetch(
      'http://localhost:3000/mobile-app/auth/create-account-apple-subscription',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(testData),
      }
    );

    console.log('Response status:', response.status);
    const result = await response.json();
    console.log('Response data:', result);
  } catch (error) {
    console.error('Test failed:', error);
  }
}

module.exports = {
  exampleAppleSubscriptionRequest,
  handleAppleSubscriptionResponse,
  testAppleSubscriptionEndpoint,
};
