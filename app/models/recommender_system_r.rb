# encoding: utf-8

###############
# Recommender System (Random recommendations)
###############

class RecommenderSystemR

  #Step 2: Scoring
  def self.calculateScore(preSelectionLOs,options)
    preSelectionLOs.map{ |lo|
      lo.score = rand
    }
    preSelectionLOs
  end

end