Office.onReady((info) => {
  if (info.host === Office.HostType.Outlook) {
    const appBody = document.getElementById("app-body");
    if (appBody) {
      appBody.style.display = "flex";
      appBody.style.flexDirection = "column"; // Set flex-direction to column
    }

    document.getElementById("helloButton").onclick = run;
  }
});

export async function run() {
  const authUrl = "https://cinteraction.nswebdevelopment.com/web/auth";

  Office.context.ui.displayDialogAsync(
    authUrl,
    { height: 50, width: 50, displayInIframe: true },
    function (asyncResult) {
      if (asyncResult.status === Office.AsyncResultStatus.Failed) {
        console.error("Dialog failed to open:", asyncResult.error.message);
        return;
      }

      const dialog = asyncResult.value;
      window.addEventListener("message", (event) => {
        if (event.origin !== "expected_origin") {
          console.error("Message received from unknown source:", event.origin);
          return;
        }

        console.log("Message received from Flutter:", event.data);
        const message = event.data;
        if (message.startsWith("success:")) {
          const accessToken = message.split(":")[1];
          console.log("Access Token:", accessToken);
        } else {
          console.error("Login failed or user canceled");
        }
      });

      dialog.addEventHandler(Office.EventType.DialogEventReceived, () => {
        console.log("Dialog closed by user or system");
      });
    }
  );
}
