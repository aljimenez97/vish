# encoding: utf-8

###############
# Content-based Recommender System + Quality Metrics
###############

class RecommenderSystemCQ

  #Step 2: Scoring
  def self.calculateScore(preSelectionLOs,options)
    preSelectionLOs.map{ |lo|
      lo.tag_array_cached = lo.tag_array
      lo.score = 0.8 * loSimilarityScore(options[:lo],lo,options) + 0.2 * qualityScore(lo)
    }
    preSelectionLOs
  end

  #Learning Object Similarity Score, [0,1] scale
  def self.loSimilarityScore(loA,loB,options={})
    titleS = getSemanticDistance(loA.title,loB.title)
    languageS = getSemanticDistanceForLanguage(loA.language,loB.language)
    keywordsS = getSemanticDistanceForKeywords(loA.tag_array_cached,loB.tag_array_cached)

    return 0.3 * titleS + 0.4 * languageS + 0.3 * keywordsS
  end

  #Quality Score, [0,1] scale
  def self.qualityScore(lo)
    return lo.reviewers_qscore_loriam.nil? ? 0 : [[lo.reviewers_qscore_loriam.to_f/10.to_f,0].max,1].min
  end


  private

  #######################
  ## Utils
  #######################

  #Semantic distance in a [0,1] scale.
  #It calculates the semantic distance using the Cosine similarity measure, and the TF-IDF function to calculate the vectors.
  def self.getSemanticDistance(textA,textB)
    return 0 if (textA.blank? or textB.blank?)

    #We need to limit the length of the text due to performance issues
    textA = textA.first(Vish::Application::config.rs_max_text_length)
    textB = textB.first(Vish::Application::config.rs_max_text_length)

    numerator = 0
    denominator = 0
    denominatorA = 0
    denominatorB = 0

    wordsTextA = processFreeText(textA)
    wordsTextB = processFreeText(textB)

    (wordsTextA.keys + wordsTextB.keys).uniq.each do |word|
      wordIDF = IDF(word)
      tfidf1 = (wordsTextA[word] || 0) * wordIDF
      tfidf2 = (wordsTextB[word] || 0) * wordIDF
      numerator += (tfidf1 * tfidf2)
      denominatorA += tfidf1**2
      denominatorB += tfidf2**2
    end

    denominator = Math.sqrt(denominatorA) * Math.sqrt(denominatorB)
    return 0 if denominator==0

    numerator/denominator
  end

  def self.processFreeText(text)
    return {} if text.blank?
    words = Hash.new
    normalizeText(text).split(" ").each do |word|
      words[word] = 0 if words[word].nil?
      words[word] += 1
    end
    words
  end

  def self.normalizeText(text)
    I18n.transliterate(text.gsub(/([\n])/," ").strip, :locale => "en").downcase
  end

  # Term Frequency (TF)
  def self.TF(word,text)
    processFreeText(text)[normalizeText(word)] || 0
  end

  # Inverse Document Frequency (IDF)
  def self.IDF(word)
    Math::log((2+Vish::Application::config.rs_repository_total_entries)/(1+(Vish::Application::config.rs_words[word] || 0)).to_f)
  end

  # TF-IDF
  def self.TFIDF(word,text)
    tf = TF(word,text)
    return 0 if tf==0
    return (tf * IDF(word))
  end

  #Semantic distance in a [0,1] scale.
  #It calculates the semantic distance for categorical fields.
  #Return 1 if both fields are equal, 0 if not.
  def self.getSemanticDistanceForCategoricalFields(stringA,stringB)
    stringA = normalizeText(stringA) rescue nil
    stringB = normalizeText(stringB) rescue nil
    return 0 if stringA.blank? or stringB.blank?
    return 1 if stringA === stringB
    return 0
  end

  #Semantic distance in a [0,1] scale.
  #It calculates the semantic distance for languages.
  def self.getSemanticDistanceForLanguage(stringA,stringB)
    return 0 if ["independent","ot"].include? stringA
    return getSemanticDistanceForCategoricalFields(stringA,stringB)
  end

  #Semantic distance in a [0,1] scale.
  #It calculates the semantic distance for keywords.
  def self.getSemanticDistanceForKeywords(keywordsA,keywordsB)
    return 0 if keywordsA.blank? or keywordsB.blank?
    # keywordsA = keywordsA.map{|k| normalizeText(k)}.uniq
    # keywordsB = keywordsB.map{|k| normalizeText(k)}.uniq
    return (2*(keywordsA & keywordsB).length)/(keywordsA.length+keywordsB.length).to_f
  end

end