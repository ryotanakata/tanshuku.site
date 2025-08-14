import { useFormHooks } from '@/components/Form/hooks';
import styles from '@/components/Form/style.module.scss';

const Form = () => {
  const {
    register,
    handleSubmit,
    watch,
    setValue,
    formState: { errors },
    onSubmit,
    copyToClipboard,
    url,
    loading,
    copied,
    generated
  } = useFormHooks();

  const renderOutputContent = () => {
    if (!url) return null;

    switch (true) {
      case copied: return <span>コピーが完了しました 🎉</span>;
      case generated: return <span>短縮URLが生成されました 🎉</span>;
      default:
        return (
          <>
            <a href={url.short_url} target="_blank" rel="noopener noreferrer">
              {url.short_url}
            </a>
            <button onClick={copyToClipboard} aria-label="コピーする">
              <span className="material-icons-round" aria-hidden="true">
                content_copy
              </span>
            </button>
          </>
        );
    }
  };

  return (
    <section className={styles.form}>
      <form onSubmit={handleSubmit(onSubmit)} noValidate>
        <fieldset>
          <legend>URL</legend>
          <div className={styles.input}>
            <input
              id="url"
              type="url"
              placeholder="https://example.com/long....."
              aria-invalid={errors.url ? 'true' : 'false'}
              disabled={loading}
              autoFocus={true}
              {...register('url')}
            />
            <button
              type="button"
              onClick={() => setValue('url', '')}
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

        {url && (
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