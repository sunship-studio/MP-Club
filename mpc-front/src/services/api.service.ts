import axios, { AxiosInstance } from "axios";

export class ApiService {
  private axiosInstance: AxiosInstance;

  constructor() {
    this.axiosInstance = axios.create({
      baseURL:
        process.env.NODE_ENV === "production"
          ? "https://api.example.com"
          : "http://localhost:3500",
      headers: {
        "Content-Type": "application/json",
      },
    });
  }
  async get<T>(url: string, params?: any): Promise<T> {
    try {
      const response = await this.axiosInstance.get<T>(url, { params });
      return response.data;
    } catch (error) {
      console.error("Error fetching data:", error);
      throw error;
    }
  }
  async post<T>(url: string, data: any): Promise<T> {
    try {
      const response = await this.axiosInstance.post<T>(url, data);
      return response.data;
    } catch (error) {
      console.error("Error posting data:", error);
      throw error;
    }
  }

  public getInstance(): AxiosInstance {
    return this.axiosInstance;
  }
}

export const apiService = new ApiService();

export default apiService;
export type DataState<T> =
  | { status: "initial" }
  | { status: "loading" }
  | { status: "success"; data: T }
  | { status: "error"; error: string };
