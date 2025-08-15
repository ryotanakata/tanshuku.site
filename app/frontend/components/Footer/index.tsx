import styles from '@/components/Footer/style.module.scss'

const Footer = () => {
  const year = new Date().getFullYear();

  return (
    <footer className={styles.footer}>
      <div>
        <p>
          &copy;{year} <span translate="no">tanshuku</span> - 短縮URL生成サービス
        </p>
      </div>
    </footer>
  )
}

export { Footer };