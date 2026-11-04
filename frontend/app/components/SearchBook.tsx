import { useState } from "react";
import axios from "axios";
import {
  API_BASE_URL,
  getApiErrorMessage,
  getAuthToken,
  normalizeBook,
} from "../utils/bookApi.ts";
import type { Book } from "../types/book.ts";

type SearchBookProps = {
  onResults: (books: Book[]) => void;
};

export default function SearchBook({ onResults }: SearchBookProps) {
  const [search, setSearch] = useState("");
  const [message, setMessage] = useState("");
  const [hasSearched, setHasSearched] = useState(false);
  const [isSearching, setIsSearching] = useState(false);

  async function searchBooks() {
    const searchText = search.trim();

    if (!searchText) {
      setMessage("Enter a title, author, or other search term.");
      setHasSearched(false);
      onResults([]);
      return;
    }

    if (isSearching) return;

    setIsSearching(true);
    setMessage("");
    setHasSearched(false);

    try {
      const response = await axios.post(`${API_BASE_URL}/library/search`, {
        search_string: searchText,
        token: getAuthToken(),
      });

      // The contract specifies 204 when no books match.
      if (response.status === 204 || !response.data) {
        onResults([]);
        setHasSearched(true);
        return;
      }

      if (response.data.status !== "success") {
        throw new Error(
          response.data.reason || "The search could not be completed.",
        );
      }

      const results = Array.isArray(response.data.library)
        ? response.data.library.map(normalizeBook)
        : [];

      onResults(results);
      setHasSearched(true);
    } catch (error) {
      onResults([]);
      setMessage(getApiErrorMessage(error, "Unable to search your library."));
    } finally {
      setIsSearching(false);
    }
  }

  return (
    <div className="books-search-wrapper">
      <div className="input-group">
        <input
          className="form-control books-search-input"
          type="search"
          aria-label="Search books"
          placeholder="Search books"
          value={search}
          onChange={(event) => {
            setSearch(event.target.value);
            setMessage("");
            setHasSearched(false);
          }}
          onKeyDown={(event) => {
            if (event.key === "Enter") {
              event.preventDefault();
              searchBooks();
            }
          }}
        />

        <button
          type="button"
          className="btn btn-dark"
          onClick={searchBooks}
          disabled={isSearching}
        >
          {isSearching ? "Searching..." : "Search"}
        </button>
      </div>

      {message && (
        <p className="text-danger text-center mt-2 mb-0" role="alert">
          {message}
        </p>
      )}

      {hasSearched && !message && (
        <p className="text-muted text-center mt-2 mb-0" role="status">
          Search completed.
        </p>
      )}
    </div>
  );
}
