module Rhymer
  class Parser
    VIBES_THRESHOLD_DEFAULT = 4
    PREFIX_LENGTH_DEFAULT = 1

    attr_reader :lyric, :rhyme

    def initialize(text, config = { :vibes_threshold => VIBES_THRESHOLD_DEFAULT, :prefix_length => PREFIX_LENGTH_DEFAULT })
      text = remove_symbols(text)
      @lyric = Lyric.new(text)
      @rhyme = []
      consonants = []

      @lyric.words.each do |word|
        consonants << {
          :position => word[0],
          :word => romanize(word[1].feature.split(",")[7])
        }
      end

      hit = Array.new(consonants.length).map{Array.new(consonants.length){false}}
      consonants.combination(2) do |arr|
        score = vibes(arr.first[:word], arr.last[:word])
        if
          arr.first[:word] != arr.last[:word] &&
          score > config[:vibes_threshold]
        then
          hit[arr.first[:position]][arr.last[:position]] = true
        end
      end

      cand_length = 0
      first_pos = 0
      last_pos = 0
      for i in 0..consonants.length
        for j in i+1..consonants.length
          if hit[i][j]
            unless
                @lyric.lyric[i].feature.split(",")[0] == @lyric.lyric[j].feature.split(",")[0]
              next
            end
            counter = 0
            while i - counter - 1 >= 0 and j - counter - 1 >= 0
              if hit[i-counter-1][j-counter- 1]
                counter += 1
              else
                break
              end
            end
            if counter > cand_length
              cand_length = counter
              first_pos = i
              last_pos = j
            end
          end
        end
      end

      if cand_length >= config[:prefix_length]
        @rhyme = [
            @lyric.lyric[first_pos-cand_length..first_pos].map{|elem| elem.feature.split(",")[6]}.join,
            @lyric.lyric[last_pos-cand_length..last_pos].map{|elem| elem.feature.split(",")[6]}.join,
        ]
      end
    end

    def remove_html(text)
      text.gsub(/<\/?[^>]*>/, "")
    end

    def remove_symbols(text)
      text.gsub(/\[.+?\]/, "")
    end

    def romanize(term)
      {
        "キャ" => "kya",
        "キュ" => "kyu",
        "キョ" => "kyo",
        "シャ" => "sya",
        "シュ" => "syu",
        "ショ" => "syo",
        "チャ" => "tya",
        "チュ" => "tyu",
        "チョ" => "tyo",
        "ニャ" => "nya",
        "ニュ" => "nyu",
        "ニョ" => "nyo",
        "ヒャ" => "hya",
        "ヒュ" => "hyu",
        "ヒョ" => "hyo",
        "ミャ" => "mya",
        "ミュ" => "myu",
        "ミョ" => "myo",
        "リャ" => "rya",
        "リュ" => "ryu",
        "リョ" => "ryo",
        "ギャ" => "gya",
        "ギュ" => "gyu",
        "ギョ" => "gyo",
        "ジャ" => "jya",
        "ジュ" => "jyu",
        "ジョ" => "jyo",
        "ビャ" => "bya",
        "ビュ" => "byu",
        "ビョ" => "byo",
        "ピャ" => "pya",
        "ピュ" => "pyu",
        "ピョ" => "pyo",
        "カ" => "ka",
        "キ" => "ki",
        "ク" => "ku",
        "ケ" => "ke",
        "コ" => "ko",
        "サ" => "sa",
        "シ" => "si",
        "ス" => "su",
        "セ" => "se",
        "ソ" => "so",
        "タ" => "ta",
        "チ" => "ti",
        "ツ" => "tu",
        "テ" => "te",
        "ト" => "to",
        "ナ" => "na",
        "ニ" => "ni",
        "ヌ" => "nu",
        "ネ" => "ne",
        "ノ" => "no",
        "ハ" => "ha",
        "ヒ" => "hi",
        "フ" => "ha",
        "ヘ" => "he",
        "ホ" => "ho",
        "マ" => "ma",
        "ミ" => "mi",
        "ム" => "mu",
        "メ" => "me",
        "モ" => "mo",
        "ヤ" => "ya",
        "ユ" => "yu",
        "ヨ" => "yo",
        "ラ" => "ra",
        "リ" => "ri",
        "ル" => "ru",
        "レ" => "re",
        "ロ" => "ro",
        "ワ" => "wa",
        "ヲ" => "wo",
        "ガ" => "ga",
        "ギ" => "gi",
        "グ" => "gu",
        "ゲ" => "ge",
        "ゴ" => "go",
        "ザ" => "za",
        "ジ" => "zi",
        "ズ" => "zu",
        "ゼ" => "ze",
        "ゾ" => "zo",
        "ダ" => "da",
        "ヂ" => "di",
        "ヅ" => "du",
        "デ" => "de",
        "ド" => "do",
        "バ" => "ba",
        "ビ" => "bi",
        "ブ" => "bu",
        "ベ" => "be",
        "ボ" => "bo",
        "パ" => "pa",
        "ピ" => "pi",
        "プ" => "pu",
        "ペ" => "pe",
        "ポ" => "po",
        "ア" => "a",
        "イ" => "i",
        "ウ" => "u",
        "エ" => "e",
        "オ" => "o",
        "ン" => "#",
        "ッ" => "*",
      }.each do |key, value|
        term = term.to_s.gsub(Regexp.new(key), value)
      end
      term
    end

    def replace_consonant(romanized_term)
      romanized_term.gsub(/[bcdfghjklmnpqrstvwxyz]/, "x")
    end

    def extract_vowel(romanized_term)
      romanized_term.gsub(/[bcdfghjklmnpqrstvwxyz]/, "")
    end

    def vibes(a, b)
      score = 0

      a = replace_consonant(a)
      b = replace_consonant(b)
      if extract_vowel(a).length < 3 || extract_vowel(b).length < 3
        return 0
      end

      if a[-2..-1] != b[-2..-1]
        return 0
      end

      if a[-4..-1] == b[-4..-1]
        score = score + 2
      end

      if a[-5..-1] == b[-5..-1]
        score = score + 4
      end

      if a[-6..-1] == b[-6..-1]
        score = score + 6
      end

      if extract_vowel(a) == extract_vowel(b)
        score = score + 8
      end

      score
    end
  end
end
