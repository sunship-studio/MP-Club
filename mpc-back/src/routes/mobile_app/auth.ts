import express from "express";
import { AuthController } from "../../controllers/mobile/auth";

const authRouter = express.Router();

authRouter.post("/check-email", async (req, res) => {
  try {
    console.log("Request body:", req.body);
    const { email } = req.body;

    const data = await AuthController.checkEmail(email);
    console.log("Email check data:", data);
    res.json({ exists: data.exists, hasPassword: data.hasPassword });
  } catch (error) {
    res.status(500).json({ message: "Error checking email" });
  }
});

authRouter.post("/set-password", async (req, res) => {
  const { email, newPassword } = req.body;
  const result = await AuthController.setPassword(email, newPassword);
  res.setHeader("authorization", result?.token || "");
  res.setHeader("x-refresh-token", result?.refreshToken || "");
  res.json({
    message: "Password set successfully",

  });
});

authRouter.post("/login", async (req, res) => {
  const { email, password } = req.body;
  const tokens = await AuthController.login(email, password);
  res.setHeader("authorization", tokens?.token || "");
  res.setHeader("x-refresh-token", tokens?.refreshToken || "");
  if (tokens) {
    res.json({
      message: "Login successful",

    });
  } else {
    res.status(401).json({ message: "Invalid email or password" });
  }
});

authRouter.post("/forgot-password", async (req, res) => {
  const { email } = req.body;
});

authRouter.get("/user", async (req, res) => {
  console.log("Getting user with token:", req.headers["authorization"]);
  const user = await AuthController.getUser(
    req.headers["authorization"] as string
  );
  res.json(user);
});



export default authRouter;
