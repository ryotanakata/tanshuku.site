import { useFormHooks } from "@/components/Main/Form/hooks";
import styles from "@/components/Main/Form/style.module.scss";

const Form = () => {
  const {
    url,
    loading,
    error,
    copied,
    generated,
    formState: { errors, isSubmitting, isValid },
    register,
    watch,
    onSubmit,
    handleSubmit,
    handleClickCopyButton,
    handleClickClearButton,
  } = useFormHooks();

  const renderOutput = () => {
    let message = "";

    if (error) message = "⚠️ 短縮に失敗しました";
    if (copied) message = "コピーが完了しました ✅";
    if (generated) message = "短縮が完了しました 🎉";

    if (message) {
      return (
        <output htmlFor="url">
          <span>{message}</span>
        </output>
      );
    }

    if (!url) return null;

    return (
      <output htmlFor="url">
        <a href={url.short_url} target="_blank" rel="noopener noreferrer">
          {url.short_url}
        </a>
        <button
          type="button"
          onClick={handleClickCopyButton}
          aria-label="コピーする"
        >
          <span className="material-icons-round" aria-hidden="true">
            content_copy
          </span>
        </button>
      </output>
    );
  };

  return (
    <section className={styles.form}>
      <form onSubmit={handleSubmit(onSubmit)} noValidate>
        <fieldset disabled={isSubmitting}>
          <legend>URL</legend>
          <div className={styles.input}>
            <input
              id="url"
              type="url"
              placeholder="https://example.com/long....."
              aria-invalid={errors.url ? "true" : "false"}
              disabled={isSubmitting || loading}
              autoFocus={true}
              {...register("url")}
            />
            <button
              type="button"
              onClick={handleClickClearButton}
              aria-label="入力内容をクリア"
              disabled={!watch("url")}
            >
              <span className="material-icons-round" aria-hidden="true">
                close
              </span>
            </button>
          </div>
          <div className={styles.error}>
            {errors.url && <p>{errors.url.message}</p>}
          </div>
          <div className={styles.output}>{renderOutput()}</div>
          <div className={styles.button}>
            <button
              type="submit"
              disabled={!isValid || isSubmitting || loading}
            >
              {isSubmitting ? "短縮中..." : "短縮する"}
            </button>
          </div>
        </fieldset>
      </form>
    </section>
  );
};

export { Form };
