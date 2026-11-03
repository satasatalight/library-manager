import { useEffect, useState } from "react";
import axios from "axios";
import AddBook from "../components/AddBook";
import EditBook from "../components/EditBook";
import DeleteBook from "../components/DeleteBook";
import SearchBook from "../components/SearchBook";
import {
  API_BASE_URL,
  getApiErrorMessage,
  getAuthToken,
  normalizeBook,
} from "../utils/bookApi.ts";
import type { Book } from "../types/book.ts";
import "../sass/books.scss";

type ActionMode = "edit" | "delete" | null;
type Dialog =
  | { type: "add" }
  | { type: "edit"; book: Book }
  | { type: "delete"; book: Book }
  | null;

export default function Books() {
  const [books, setBooks] = useState<Book[]>([]);
  const [message, setMessage] = useState("");
  const [isLoading, setIsLoading] = useState(true);
  const [actionMode, setActionMode] = useState<ActionMode>(null);
  const [isSearchOpen, setIsSearchOpen] = useState(false);
  const [searchResults, setSearchResults] = useState<Book[]>([]);
  const [dialog, setDialog] = useState<Dialog>(null);

  useEffect(() => {
    async function loadLibrary() {
      setIsLoading(true);
      setMessage("");

      try {
        const response = await axios.post(`${API_BASE_URL}/library/view`, {
          token: getAuthToken(),
        });

        if (response.data?.status !== "success") {
          throw new Error(
            response.data?.reason || "Your library could not be loaded.",
          );
        }

        const library = response.data.library;

        // example data
        // uncomment this to test
        // const library = [
          // {
            // book_id: 1,
            // title: "example",
            // author: "mr. example",
            // genre: "example-like",
            // publication_year: 1000,
            // description: "this is an example",
            // cover_image: null
          // }
        // ];

        setBooks(Array.isArray(library) ? library.map(normalizeBook) : []);
      } catch (error) {
        setBooks([]);
        setMessage(getApiErrorMessage(error, "Unable to load your library."));
      } finally {
        setIsLoading(false);
      }
    }

    void loadLibrary();
  }, []);

  function addBook(book: Book) {
    setBooks((current) => [...current, book]);
    setDialog(null);
  }

  function saveBook(updatedBook: Book) {
    setBooks((current) =>
      current.map((book) => (book.id === updatedBook.id ? updatedBook : book)),
    );
    setDialog(null);
    setActionMode(null);
  }

  function removeBook(bookId: number) {
    setBooks((current) => current.filter((book) => book.id !== bookId));
    setDialog(null);
    setActionMode(null);
  }

  function handleBookClick(book: Book) {
    if (actionMode === "edit") {
      setDialog({ type: "edit", book });
    } else if (actionMode === "delete") {
      setDialog({ type: "delete", book });
    }
  }

  function toggleMode(mode: Exclude<ActionMode, null>) {
    setActionMode((current) => (current === mode ? null : mode));
  }

  return (
    <main className="books-page bg-base min-vh-100 w-100">
      <div className="books-main container border-start border-end shadow-lg mx-auto px-4 px-md-5 pt-5 min-vh-100 w-75">
        <div className="d-flex justify-content-end mb-3">
          <button
            type="button"
            className="btn rounded-pill px-4 bg-white border border-2 border-dark text-dark"
            onClick={() => {
              sessionStorage.removeItem("token");
              window.location.href = "/";
            }}
          >
            Logout
          </button>
        </div>

        <h1 className="books-heading font-kurale text-center mb-4">Books</h1>

        <div className="books-toolbar d-flex flex-wrap align-items-center justify-content-center gap-2 mb-4">
          <button
            type="button"
            className={`books-icon-button ${isSearchOpen ? "is-active" : ""}`}
            aria-label="Search books"
            aria-pressed={isSearchOpen}
            title="Search your library"
            onClick={() => {
              setActionMode(null);
              setSearchResults([]);
              setIsSearchOpen((current) => !current);
            }}
          >
            🔍
          </button>
          <button
            type="button"
            className={`books-icon-button ${actionMode === "delete" ? "is-active" : ""}`}
            aria-label="Delete a book"
            aria-pressed={actionMode === "delete"}
            title="Select a book to delete"
            onClick={() => toggleMode("delete")}
          >
            🗑️
          </button>

          <button
            type="button"
            className="books-icon-button"
            aria-label="Add a book"
            title="Add a book"
            onClick={() => {
              setActionMode(null);
              setDialog({ type: "add" });
            }}
          >
            ➕
          </button>

          <button
            type="button"
            className={`books-icon-button ${actionMode === "edit" ? "is-active" : ""}`}
            aria-label="Edit a book"
            aria-pressed={actionMode === "edit"}
            title="Select a book to edit"
            onClick={() => toggleMode("edit")}
          >
            ✏️
          </button>
        </div>

        {isSearchOpen && (
          <div className="d-flex justify-content-center mb-4">
            <SearchBook onResults={setSearchResults} />
          </div>
        )}

        {actionMode && (
          <p className="books-action-hint text-center mb-3" role="status">
            {actionMode === "edit"
              ? "Select a book below to edit it. Click the pencil again to cancel."
              : "Select a book below to delete it. Click the trash can again to cancel."}
          </p>
        )}

        {message && (
          <p className="text-danger text-center mb-3" role="alert">
            {message}
          </p>
        )}

        <section className="books-list mx-auto" aria-label="Book list">
          {isLoading ? (
            <p className="text-center py-4 mb-0">Loading your library...</p>
          ) : (isSearchOpen ? searchResults : books).length > 0 ? (
            (isSearchOpen ? searchResults : books).map((book) => (
              <article
                className={`book-list-item ${actionMode ? "book-list-item--action" : ""}`}
                key={book.id}
              >
                {actionMode ? (
                  <button
                    type="button"
                    className="book-list-item__select"
                    onClick={() => handleBookClick(book)}
                  >
                    <img
                      className="book-list-item__cover"
                      src={
                        book.coverImageUrl.trim() ||
                        `${import.meta.env.BASE_URL}DefaultBook.png`
                      }
                      alt={`Cover of ${book.title}`}
                    />

                    <span className="book-list-item__text">
                      <span className="book-list-item__title">
                        {book.title}
                      </span>
                      <span className="book-list-item__details">
                        {[book.author, book.genre, book.year]
                          .filter(Boolean)
                          .join(" · ")}
                      </span>
                      <span className="book-list-item__description">
                        {book.description}
                      </span>
                    </span>
                  </button>
                ) : (
                  <div className="book-list-item__content">
                    <img
                      className="book-list-item__cover"
                      src={
                        book.coverImageUrl.trim() ||
                        `${import.meta.env.BASE_URL}DefaultBook.png`
                      }
                      alt={`Cover of ${book.title}`}
                    />

                    <div className="book-list-item__text">
                      <span className="book-list-item__title">
                        {book.title}
                      </span>
                      <span className="book-list-item__details">
                        {[book.author, book.genre, book.year]
                          .filter(Boolean)
                          .join(" · ")}
                      </span>
                      <span className="book-list-item__description">
                        {book.description}
                      </span>
                    </div>
                  </div>
                )}
              </article>
            ))
          ) : (
            <p className="text-center py-4 mb-0">
              {isSearchOpen
                ? "No matching books to display."
                : "Your library is empty."}
            </p>
          )}
        </section>
      </div>

      {dialog?.type === "add" && (
        <AddBook onAdd={addBook} onCancel={() => setDialog(null)} />
      )}

      {dialog?.type === "edit" && (
        <EditBook
          key={dialog.book.id}
          book={dialog.book}
          onSave={saveBook}
          onCancel={() => setDialog(null)}
        />
      )}

      {dialog?.type === "delete" && (
        <DeleteBook
          book={dialog.book}
          onConfirm={() => removeBook(dialog.book.id)}
          onCancel={() => setDialog(null)}
        />
      )}
    </main>
  );
}
