async function sendMessage() {
  const msg = document.getElementById("msg").value;
  const responseBox = document.getElementById("response");

  const res = await fetch("YOUR_API_GATEWAY_URL", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ message: msg })
  });

  const result = await res.json();
  responseBox.innerText = JSON.stringify(result);
}
