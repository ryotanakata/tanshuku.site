import { useFormHooks } from '@/components/Main/Form/hooks';
import styles from '@/components/Main/Form/style.module.scss';

const Form = () => {
  const {
    url,
    loading,
    error,
    copied,
    generated,
    formState: { errors, isSubmitting },
    register,
    watch,
    onSubmit,
    handleSubmit,
    handleClickCopyButton,
    handleClickClearButton,
  } = useFormHooks();


  const renderOutputContent = () => {
    if (error) return <span>⚠️短縮URLの生成に失敗しました</span>;
    if (copied) return <span>コピーが完了しました 🎉</span>;
    if (generated) return <span>短縮URLが生成されました 🎉</span>;
    if (!url) return null;

    return (
      <>
        <a href={url.short_url} target="_blank" rel="noopener noreferrer">
          {url.short_url}
        </a>
        <button onClick={handleClickCopyButton} aria-label="コピーする">
          <span className="material-icons-round" aria-hidden="true">
            content_copy
          </span>
        </button>
      </>
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
              aria-invalid={errors.url ? 'true' : 'false'}
              disabled={isSubmitting || loading}
              autoFocus={true}
              {...register('url')}
            />
            <button
              type="button"
              onClick={handleClickClearButton}
              aria-label="入力内容をクリア"
              disabled={!watch('url')}
            >
              <span className="material-icons-round" aria-hidden="true">
                close
              </span>
            </button>
          </div>
          {errors.url && (
            <span>{errors.url.message}</span>
          )}
        </fieldset>

        {!errors.url && (
          <div className={styles.output}>
            <output htmlFor="url">
              {renderOutputContent()}
            </output>
          </div>
        )}
      </form>
    </section>
  )
}

export { Form };