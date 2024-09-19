import axios from "axios";
import { getToken } from '../sections/auth/AuthService';

export default axios.create({
  baseURL: "CLOUD_FUNCTION_URL",
  headers: {
    "Content-type": "application/json",
    "jwt-token": getToken(),
  }
});