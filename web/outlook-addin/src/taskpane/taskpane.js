import { signInEmailPass } from "./auth";

Office.onReady((info) => {
  if (info.host === Office.HostType.Outlook) {
    const appBody = document.getElementById("app-body");
    if (appBody) {
      appBody.style.display = "flex";
      appBody.style.flexDirection = "column";
    }

    document.getElementById("helloButton").onclick = run;
  }
});

export async function run() {
  const email = "superadmin@mail.com";
  const password = "password";

  const loginResult = await signInEmailPass(email, password);

  if (loginResult.success) {
    const accessToken = loginResult.data.access_token;

    Office.context.mailbox.getCallbackTokenAsync({ isRest: true }, async function (result) {
      if (result.status === "succeeded") {
        const callbackToken = result.value;

        console.log("accessToken", accessToken);
        console.log("callbackToken", callbackToken);

        // Pozivanje funkcije za kreiranje sastanka
        // await scheduleMeeting(callbackToken);
      } else {
        console.error("Failed to get callback token: " + result.error.message);
      }
    });
  } else {
    console.error("Login failed:", loginResult.error);
  }
}

// async function scheduleMeeting(callbackToken) {
//   const meetingData = {
//     subject: "Sastanak sa timom",
//     body: {
//       contentType: "HTML",
//       content: "Diskusija o projektu.",
//     },
//     start: {
//       dateTime: "2024-11-23T10:00:00",
//       timeZone: "Europe/Belgrade",
//     },
//     end: {
//       dateTime: "2024-11-23T11:00:00",
//       timeZone: "Europe/Belgrade",
//     },
//     attendees: [
//       {
//         emailAddress: {
//           address: "kljestan.radovan@gmial.com",
//           name: "Participant Name",
//         },
//         type: "required",
//       },
//     ],
//   };

//   try {
//     const response = await fetch("https://graph.microsoft.com/v1.0/me/events", {
//       method: "POST",
//       headers: {
//         Authorization: `Bearer ${callbackToken}`,
//         "Content-Type": "application/json",
//       },
//       body: JSON.stringify(meetingData),
//     });

//     if (response.ok) {
//       const event = await response.json();
//       console.log("Meeting created:", event);
//     } else {
//       const error = await response.json();
//       console.error("Error creating meeting:", error);
//     }
//   } catch (error) {
//     console.error("Error while creating meeting:", error);
//   }
// }
