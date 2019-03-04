# encoding: utf-8

###############
# Recommender System based on Quality Metrics
###############

class RecommenderSystemQ

  #Step 2: Scoring
  def self.calculateScore(preSelectionLOs,options)
    preSelectionLOs.map{ |lo|
      lo.score = qualityScore(lo)
    }
    preSelectionLOs
  end

  #Quality Score, [0,1] scale
  def self.qualityScore(lo)
    return lo.reviewers_qscore_loriam.nil? ? 0 : [[lo.reviewers_qscore_loriam.to_f/10.to_f,0].max,1].min
  end

end