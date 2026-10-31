import type { Book } from "./AddBook";

type DeleteBookProps = {
  book: Book;
  onConfirm: () => void;
  onCancel: () => void;
};

export default function DeleteBook({
  book,
  onConfirm,
  onCancel,
}: DeleteBookProps) {
  return (
    <div
      className="book-dialog-backdrop"
      onMouseDown={(event) => {
        if (event.target === event.currentTarget) onCancel();
      }}
    >
      <section
        className="book-dialog bg-base shadow-lg p-4 p-md-5 text-center"
        role="alertdialog"
        aria-modal="true"
        aria-labelledby="delete-book-heading"
        aria-describedby="delete-book-description"
      >
        <h2 id="delete-book-heading" className="font-kurale mb-3">
          Delete Book?
        </h2>
        <p id="delete-book-description" className="mb-4">
          Are you sure you want to delete <strong>{book.title}</strong>?
        </p>
        <div className="d-flex justify-content-center gap-3">
          <button
            type="button"
            className="btn btn-outline-dark"
            onClick={onCancel}
          >
            Cancel
          </button>
          <button type="button" className="btn btn-dark" onClick={onConfirm}>
            Confirm
          </button>
        </div>
      </section>
    </div>
  );
}
