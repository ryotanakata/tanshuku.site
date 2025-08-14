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
    error,
  } = useFormHooks();

  return (
    <section className={styles.form}>
      <form onSubmit={handleSubmit(onSubmit)}>
        <fieldset>
          <legend>URL</legend>
          <div className={styles.input}>
            <input
              type="url"
              placeholder="URLを入力してください"
              aria-invalid={errors.url ? 'true' : 'false'}
              disabled={loading}
              {...register('url')}
            />
            <button
              type="button"
              onClick={() => setValue('url', '')}
              aria-label="入力内容をクリア"
              disabled={!watch('url')}
            >
              <span className="material-icons-round">
                close
              </span>
            </button>
          </div>
          {errors.url && (
            <span>{errors.url.message}</span>
          )}
      </fieldset>
        {/* <div className={styles.button}>
          <button
            type="button"
            disabled={loading || isSubmitting || !url}
          >
            {loading ? '処理中...' : '短縮する'}
          </button>
        </div> */}
      </form>

      {error && (
        <div className="error">
          <p>{error}</p>
        </div>
      )}

      {url && (
        <div className="result">
          <h3>短縮完了！</h3>
          <div className="url-info">
            <p><strong>元のURL:</strong> {url.original_url}</p>
            <p><strong>短縮URL:</strong>
              <a href={url.short_url} target="_blank" rel="noopener noreferrer">
                {url.short_url}
              </a>
              <button
                onClick={() => copyToClipboard(url.short_url)}
                className="copy-btn"
              >
                コピー
              </button>
            </p>
            <p><strong>作成日時:</strong> {new Date(url.created_at).toLocaleString('ja-JP')}</p>
          </div>
        </div>
      )}
    </section>
  )
}

export { Form };