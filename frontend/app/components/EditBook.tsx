import type { Book } from "./AddBook";

type EditBookProps = {
  book: Book;
  onSave: (book: Book) => void;
  onCancel: () => void;
};

export default function EditBook({ onCancel }: EditBookProps) {
  return (
    <div className="position-fixed top-0 start-0 w-100 h-100 d-flex align-items-center justify-content-center bg-dark bg-opacity-50">
      <section
        className="bg-white rounded shadow p-4 text-center"
        role="dialog"
        aria-modal="true"
      >
        <h2>EditBook component to be added later</h2>

        <button
          type="button"
          className="btn btn-outline-dark mt-3"
          onClick={onCancel}
        >
          Close
        </button>
      </section>
    </div>
  );
}
