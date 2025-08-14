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
    copied
  } = useFormHooks();



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
              <span className="material-icons-round">
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
              🎉
              {copied ? (
                <span>コピーが完了しました！</span>
              ) : (
                <a href={url.short_url} target="_blank" rel="noopener noreferrer">
                  {url.short_url}
                </a>
              )}
              <button
                onClick={copyToClipboard}
                aria-label="コピーする"
              >
                <span className="material-icons-round">
                  content_copy
                </span>
              </button>
            </output>
          </div>
        )}
      </form>
    </section>
  )
}

export { Form };