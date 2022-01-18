module I18nHelper
  def translate(key, options={})
    if missing?(key,I18n.locale)
      #find case insensitive match
      I18n.backend.send(:init_translations) unless I18n.backend.initialized?
      alt_key = I18n.backend.send(:translations)[:en].keys.find{|k| k.to_s.downcase==key.to_s.downcase}
      key = alt_key||key
      if alt_key.blank? && I18N_AUTOFILL
        autofill(I18n.default_locale.to_s, key, options)
      end
    end
    super(key, options.merge(raise: true))
  rescue I18n::MissingTranslationData
    I18n.locale==I18n.default_locale ? key : (I18N_MISSING_FORMAT % {key: key, locale: I18n.locale})
  end
  alias :t :translate

  def missing?(key, locale)
    t = I18n.backend.send(:translations)[locale][key] rescue nil
    return t.nil?
  end

  def autofill(locale, key, options)
    if missing?(key, locale.to_sym)
      #new = (options.blank?)? key : (I18N_AUTOFILL_FORMAT % {key: key options: options.map{|o|'%{'+o[0].to_s+'}'}.join(' ')})
      new = (options.blank?)? key : (I18N_AUTOFILL_FORMAT % {key: key, options: options.keys.map{|o|"%{#{o}}"}.join(' ')})
      update_locale(locale, {key=>new})
    end
  end

  def update_locale(locale, keys={})
    path = get_locale_path(locale)
    data = YAML.load_file path
    data[locale].update(keys)
    File.open(path, 'w') { |f| YAML.dump(data, f) }
  end

  def get_locale_path(locale)
    return I18n.load_path.select{|f| (f.include?"#{Rails.root}/config/locales/#{locale}.yml")}.first
  end

  def alphabetize_locale(locale)
    path = get_locale_path(locale)
    data = YAML.load_file path
    data[locale] = Hash[*data[locale].sort_by{|k,v| k}.flatten]
    File.open(path, 'w') { |f| YAML.dump(data, f) }
  end
end