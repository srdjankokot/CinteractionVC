import axios from "axios";

export async function signInEmailPass(email, password) {
  console.log("calledFunc");

  const loginUrl = "https://huawei.nswebdevelopment.com/api/login";

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

export async function scheduleMeet(name, description, tag, startDateTime, localTimeZone, accessToken) {
  const scheduleUrl = "https://huawei.nswebdevelopment.com/api/schedule/meeting";

  const params = {
    name,
    description,
    tag,
    startDateTime,
    localTimeZone,
  };

  try {
    const response = await axios.post(scheduleUrl, params, {
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
    });
    return { success: true, data: response.data };
  } catch (error) {
    console.error("Schedule error:", error.response ? error.response.data : error.message);
    return {
      success: false,
      error: error.response ? error.response.data : error.message,
    };
  }
}

window.scheduleMeet = scheduleMeet;
