import axios from "axios";
import type { Book } from "../types/book";


export const API_BASE_URL = "https://library-manager-ashy.vercel.app";

export function getAuthToken(): string {
  const token = sessionStorage.getItem("token");

  if (!token) {
    throw new Error("Your session has expired. Please log in again.");
  }

  return token;
}

export function getApiErrorMessage(error: unknown, fallback: string): string {
  if (axios.isAxiosError(error)) {
    const reason = error.response?.data?.reason;

    if (typeof reason === "string" && reason.trim()) {
      return reason;
    }
  }

  if (error instanceof Error && error.message) {
    return error.message;
  }

  return fallback;
}


export function normalizeBook(value: unknown): Book {
  if (!value || typeof value !== "object") {
    throw new Error("The server returned an invalid book.");
  }

  const book = value as Record<string, unknown>;
  const rawId = book.book_id ?? book.id ?? book._id;
  const id = Number(rawId);

  if (!Number.isFinite(id)) {
    throw new Error("The server returned a book without a valid ID.");
  }

  const rawYear = book.publication_year ?? book.year;
  const year =
    rawYear === null || rawYear === undefined || rawYear === ""
      ? null
      : Number(rawYear);

  return {
    id,
    title: typeof book.title === "string" ? book.title : "",
    author: typeof book.author === "string" ? book.author : "",
    genre: typeof book.genre === "string" ? book.genre : "",
    year: year !== null && Number.isFinite(year) ? year : null,
    description: typeof book.description === "string" ? book.description : "",
    coverImageUrl:
      typeof book.cover_image === "string"
        ? book.cover_image
        : typeof book.coverImageUrl === "string"
          ? book.coverImageUrl
          : "",
  };
}
