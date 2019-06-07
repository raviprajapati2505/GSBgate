module ApiHelper
  def sum_score_hashes(score_hashes)
    # create a result hash, using the same keys as the input hashes, but with zero values
    total_score = score_hashes[0].dup
    total_score.each{|k,v| total_score[k]=0}
    # Sum the input hashes
    score_hashes.inject(total_score) { |total, score|
      total.each{|k,v|
        # if any input has a nil for a given key, the sum shall be nil also !!
        if (total[k].nil? || score[k].nil?)
          total[k] = nil
        else
          total[k] = total[k] + score[k]
        end
      }
    }
  end
end