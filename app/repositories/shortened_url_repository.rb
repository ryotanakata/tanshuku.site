class ShortenedUrlRepository
  def create(attributes)
    shortened_url = ShortenedUrl.new(attributes)
    shortened_url.save
    shortened_url
  end

  def find_by_short_code(short_code)
    ShortenedUrl.find_by(short_code: short_code.upcase)
  end

  def find_by_original_url(original_url)
    ShortenedUrl.find_by(original_url: original_url)
  end

  def exists?(short_code)
    ShortenedUrl.exists?(short_code: short_code.upcase)
  end

  def all
    ShortenedUrl.all
  end

  def delete(id)
    shortened_url = ShortenedUrl.find(id)
    shortened_url.destroy
  rescue ActiveRecord::RecordNotFound
    false
  end
end
