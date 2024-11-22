import axios from "axios";

export async function signInEmailPass(email, password) {
  const loginUrl = "https://cinteraction.nswebdevelopment.com/api/login";

  try {
    const response = await axios.post(
      loginUrl,
      { email, password },
      {
        headers: {
          "Content-Type": "application/json",
        },
      }
    );

    const loginResponse = response.data;
    return { success: true, data: loginResponse };
  } catch (error) {
    return {
      success: false,
      error: error.response ? error.response.data : error.message,
    };
  }
}
