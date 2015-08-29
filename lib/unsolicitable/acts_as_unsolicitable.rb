module Unsolicitable
  module ActsAsUnsolicitable

    attr_reader :unsolicitable_score

    extend ActiveSupport::Concern

    included do

    end

    LINKS_REGEXP = %r{
      (?: ((?:ed2k|ftp|http|https|irc|mailto|news|gopher|nntp|telnet|webcal|xmpp|callto|feed|svn|urn|aim|rsync|tag|ssh|sftp|rtsp|afs|file):)// | www\. )
      [^\s<\u00A0"]+
    }ix

    BAD_WORDS_REGEXP = [
      /^(?:Re:|\[.{1,10}\])?\s*(?:very )?urgent\s+(?:(?:and|&)\s+)?(?:confidential|assistance|business|attention|reply|response|help)\b/i,
      /(?:\bdollars?\b|\busd(?:ollars)?(?:[0-9]|\b)|\bus\$|\$[0-9,.]{6,}|\$[0-9].{0,8}[mb]illion|\$[0-9.,]{2,10} ?m|\beuros?\b|u[.]?s[.]? [0-9.]+ m)/i,
      /(?:claim|concerning) (?:the|this) money/i,
      /(?:finance|holding|securit(?:ies|y)) (?:company|firm|storage house)/i,
      /(?:government|bank) of nigeria/i,
      /(?:who was a|as a|an? honest|you being a|to any) foreigner/i,
      /\b(?:(?:respond|reply) (?:urgently|immediately)|(?:urgent|immediate|earliest) (?:reply|response))\b/i,
      /\b(?:ass?ass?inat(?:ed|ion)|murder(?:e?d)?|kill(?:ed|ing)\b[^.]{0,99}\b(?:war veterans|rebels?))\b/i,
      /\b(?:bank of nigeria|central bank of|trust bank|apex bank|amalgamated bank)\b/i,
      /\b(?:business partner(?:s|ship)?|silent partner(?:s|ship)?)\b/i,
      /\b(?:charles taylor|serena|abacha|gu[eéè]i|sese[- ]?seko|kabila)\b/i,
      /\b(?:compliments? of the|dear friend|dear sir|yours faithfully|season'?s greetings)\b/i,
      /\b(?:confidential|private|alternate|alternative) (?:(?:e-? *)?mail)\b/i,
      /\b(?:disburse?(?:ment)?|incurr?(?:ed)?|remunerr?at(?:ed?|ion)|remm?itt?(?:ed|ance|ing)?)\b/i,
      /\b(?:in|to|visit) your country\b/i,
      /\b(?:my name is|i am) (?:mrs?|engr|barrister|dr|prince(?:ss)?)[. ]/i,
      /\b(?:no risks?|risk-? *free|free of risks?|100% safe)\b/i,
      /\b(?:of|the) late president\b/i,
      /\b(?:reply|respond)\b[^.]{0,50}\b(?:to|through)\b[^.]{0,50}\@\b/i,
      /\b(?:wife|son|brother|daughter) of the late\b/i,
      /\bU\.?S\.?(?:D\.?)?\s*(?:\$\s*)?(?:\d+,\d+,\d+|\d+\.\d+\.\d+|\d+(?:\.\d+)?\s*milli?on)/i,
      /\baffidavits?\b/i,
      /\battached to ticket number\b/i,
      /\bdisburs/i,
      /\bforeign account\b/i,
      /\bfurnish you with\b/i,
      /\bgive\s+you .{0,15}(?:fund|money|total|sum|contact|percent)\b/i,
      /\bhonest cooperation\b/i,
      /\blegitimate business(?:es)?\b/i,
      /\blocate(?: .{1,20})? extended relative/i,
      /\bmilli?on (?:.{1,25} thousand\s*)?(?:(?:united states|u\.?s\.?) dollars|(?i:U\.?S\.?D?))\b/i,
      /\boperat(?:e|ing)\b[^.]{0,99}\b(?:for(?:ei|ie)gn|off-? ?shore|over-? ?seas?) (?:bank )?accounts?\b/i,
      /\bover-? *(?:invoiced?|cost(?:s|ing)?)\b/i,
      /\bprivate lawyer\b/i,
      /\bsecur(?:e|ing) (?:the )?(?:funds?|monies)\b/i,
      /\bthe desk of\b/i,
      /\btransaction\b.{1,30}\b(?:magnitude|diplomatic|strict|absolute|secret|confiden(?:tial|ce)|guarantee)/i,
      /\byour\b[^.]{0,99}\b(?:contact (?:details|information)|private (?:e?[- ]?mail|telephone|tel|phone|fax))\b/i,
      /as the beneficiary/i,
      /award notification/i,
      /computer ballot system/i,
      /fiduciary agent/i,
      /foreign (?:business partner|customer)/i,
      /foreign (?:offshore )?(?:bank|account)/i,
      /god gives .{1,10}second chance/i,
      /i am contacting you/i,
      /lott(?:o|ery) (?:co,?ordinator|international)/i,
      /magnanimity/i,
      /modalit(?:y|ies)/i,
      /nigerian? (?:national|government)/i,
      /over-invoice/i,
      /the total sum/i,
      /vital documents/i,
      /\bc[\sc]{0,2}i[\si]{0,2}a[\sa]{0,2}l[\sl]{0,2}i[\si]{0,2}s{1,3}\b/i,
      /l.{0,2}e.{0,2}v.{0,2}i.{0,2}t.{0,2}r.{0,2}a/i,
      /\bs.{0,1}o.{0,1}m.{0,1}a\b/i,
      /v.{0,2}a.{0,2}l.{0,2}i.{0,2}u.{0,2}m/i,
      /x.{0,2}a.{0,2}n.{0,2}a.{0,2}x/i,
      /\b(?:CIALIS|LEVITRA|VIAGRA)/,
      /\bsildenafil\b/i,
      /\bGeneric Viagra\b/,
      /\bviagra .{0,25}(?:express|online|overnight)/i,
      /\bonline pharmacy|\b(?:drugs|medications) online/i,
      /N[o0].{1,10}P(?:er|re)scr[i1]pt[i1][o0]n.{1,10}(?:n[e3][e3]d[e3]d|requ[1i]re|n[e3]c[e3]ssary)/i,
      /\bvia.gra\b/i,
      /\bViagra\b/i,
      /\bCialis\b/i,
      /\bLevitra\b/i,
      /\bV(?:agira|igara|iaggra|iaegra)\b/i,
      /\bC(?:alis|ilias|ilais)\b/i,
      /\bphentermine\b/i,
      /\bbontril\b/i,
      /\bphendimetrazine\b/i,
      /\bdiethylpropion\b/i,
      /vicodin/i,
      /vioxx/i,
      /fioricet/i,
      /\bzebutal\b/i,
      /\besgic plus\b/i,
      /\bskelaxin\b/i,
      /xan[ae]x/i,
      /valium/i,
      /\bAlprazolam\b/i,
      /\bklonopin\b/i,
      /\brivotril\b/i,
      /(?:Viagra|Valium|Xanax|Soma|Cialis){2}/i,
      /\bfree (?:porn|xxx|adult)/i,
      /\bcum[ -]?shots?\b/i,
      /\blive .{0,9}(?:fuck(?:ing)?|sex|naked|girls?|virgins?|teens?|porno?)\b/i,
      /100% GUARANTEED/i,
      /^\s*Dear Friend\b/i,
      /\bDear (?:IT\W|Internet|candidate|sirs?|madam|investor|travell?er|car shopper|web)\b/i,
      /[BM]ILLION DOLLAR/,
      /To Be Removed,? Please/i,
      /to be removed from.{0,20}(?:mailings|offers)/i,
      /strong buy/i,
      /\bstock alert/i,
      /not a registered investment advisor/i,
      /prestigi?ous\b.{0,20}\bnon-accredited\b.{0,20}\buniversities/i,
      /\b(?:enlarge|increase|grow|lengthen|larger\b|bigger\b|longer\b|thicker\b|\binches\b).{0,50}\b(?:penis|male organ|pee[ -]?pee|dick|sc?hlong|wh?anger|breast(?!\s+cancer))/i,
      /\b(?:penis|male organ|pee[ -]?pee|dick|sc?hlong|wh?anger|breast(?!\s+cancer)).{0,50}\b(?:enlarge|increase|grow|lengthen|larger\b|bigger\b|longer\b|thicker\b|\binches\b|size)/i,
      /\b(?:impotence (?:problem|cure|solution)|Premature Ejaculation|erectile dysfunction)/i,
      /urgent.{0,16}(?:assistance|business|buy|confidential|notice|proposal|reply|request|response)/i,
      /money back guarantee/i,
      /free.{0,12}(?:(?:instant|express|online|no.?obligation).{0,4})+.{0,32}\bquote/i,
      /\b(?:bad|poor|no\b|eliminate|repair|(?:re)?establish|damag).{0,10} (?:credit|debt)\b/i,
      /\brefinance your(?: current)? (?:home|house)\b/i,
      /time to refinance|refinanc\w{1,3}\b.{0,16}\bnow\b/i,
      /\bno medical exam/i,
      /\b(?:(?:without|no) (?:exercis(?:e(?! price)|ing)|dieting)|weight.?loss|(?:extra|lose|lost|losing).{0,10}(?:pounds|weight|inches|lbs)|burn.{1,10}fat)\b/i,
      /\bfinancial(?:ly)? (?:free|independen)/i,
      /\bcontains forward-looking statements\b/i,
      /\bone\W+time (?:charge|investment|offer|promotion)/i,
      /\bjoin (?:millions|thousands)\b/i,
      /\b(?:marketing|network) partner|\bpartner (?:web)?site/i,
      /\blow.{0,4} (?-i:P)rice/i,
      /\bunclaimed\s(?:assets?|accounts?|mon(?:ey|ies)|balance|funds?|prizes?|rewards?|payments?|deposits?)\b/i,
      /\w+\^\S+\(\w{2,4}\b/,
      /\boprah!/i,
      /\bA(?i:ct) N(?i:ow)\b/,
      /increased?.{0,9}(?:sex|stamina)/i,
      /\bguaranteed?\!/i,
      /\binvestment advice/i,
      /male enhancement/i,
      /\baffordable .{0,10}prices\b/i,
      /\breplica.{1,20}rolex/i,
      /[^\s\w.]rolex/i
    ]

    STARTS_WITH_REGEXP = %r{
      \A\s*(interesting|sorry|nice|cool)
    }i

    module ClassMethods

      def acts_as_unsolicitable(options = {})
        cattr_accessor :unsolicitable_name_field,
                       :unsolicitable_email_field,
                       :unsolicitable_content_field
        
        self.unsolicitable_name_field = (options[:name_field] || :name).to_s
        self.unsolicitable_email_field = (options[:email_field] || :email).to_s
        self.unsolicitable_content_field = (options[:content_field] || :content).to_s
        
        include Unsolicitable::ActsAsUnsolicitable::LocalInstanceMethods
      end

    end

    module LocalInstanceMethods

      def calculate_score
        @unsolicitable_score = 0
        
        if LINKS_REGEXP.match(self.content).try(:size).to_i <= 1
          # +2 if 1 or 0 links are present
          @unsolicitable_score += 2
        else
          LINKS_REGEXP.match(self.content) { |link|
            # -1 for every link over 1
            @unsolicitable_score -= 1
            
            # -1 if the URL contains certain phrases
            /(\.html|free|&|\.info|\?)/i.match(link) { |bad_link|
              @unsolicitable_score -= 1
            }
            
            # -1 if the URL is long
            /.{30,}/i.match(link) { |long_link|
              @unsolicitable_score -= 1
            }
          }
        end
        
        # -1 for every bad word in the message
        BAD_WORDS_REGEXP.map { |regexp|
          regexp.match(self.content) { |m|
            @unsolicitable_score -= 1
          }
        }
        
        # -10 if the messages starts with something generic
        STARTS_WITH_REGEXP.match(self.content) { |term|
          @unsolicitable_score -= 10
        }
        
        # +1 for every previous comment from the same email address
        # if self.respond_to?(:email)
        #   @unsolicitable_score += self.class.where(email: self.email).count
        # end
        
        # @unsolicitable_score += self.class.where(:"#{self.unsolicitable_email_field}" => self.unsolicitable_email_field)
        
        @unsolicitable_score
      end

      def solicited?
        @unsolicitable_score ||= calculate_score
        @unsolicitable_score >= 1
      end

      def unsolicited?
        !solicited?
      end

    end

  end
end

ActiveRecord::Base.send :include, Unsolicitable::ActsAsUnsolicitable
