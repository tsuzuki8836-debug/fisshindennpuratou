/**
 * 全角→半角変換
 *
 * @param value 変換元文字列
 * @return 半角文字列
 */
public class ReplaceChar {
    public String convertFullToHalf(String value) {
        String result;
        // 変換内容がない場合
        if(String.isEmpty(value)) {
            result = '';
        }else{
            // 半角文字のみなら以降スキップ
            if (Pattern.matches('[ -~]+', value)) {
                result = value;
            }else{
                Map<String, String> fulltoHalfMap2 = new Map<String, String>();
                fulltoHalfMap2.put( '０',  '0' );
                fulltoHalfMap2.put( '１',  '1' );
                fulltoHalfMap2.put( '２',  '2' );
                fulltoHalfMap2.put( '３',  '3' );
                fulltoHalfMap2.put( '４',  '4' );
                fulltoHalfMap2.put( '５',  '5' );
                fulltoHalfMap2.put( '６',  '6' );
                fulltoHalfMap2.put( '７',  '7' );
                fulltoHalfMap2.put( '８',  '8' );
                fulltoHalfMap2.put( '９',  '9' );
                // エスケープ必要文字
                Set<String> escapeChars = new Set<String>();
                escapeChars.add('\\');
                escapeChars.add('*');
                escapeChars.add('+');
                escapeChars.add('.');
                escapeChars.add('?');
                escapeChars.add('{');
                escapeChars.add('}');
                escapeChars.add('(');
                escapeChars.add(')');
                escapeChars.add('[');
                escapeChars.add(']');
                escapeChars.add('^');
                escapeChars.add('$');
                escapeChars.add('|');
                escapeChars.add('/');
    
                for (String key : fulltoHalfMap2.keySet()) {
                    if (value.contains(key)) {
                        String tempKey = key;
                        if (escapeChars.contains(tempKey)) {
                            tempKey = '\\' + tempKey;
                        }
                        value = value.replaceAll(tempKey, fulltoHalfMap2.get(key));
                    }
                }
                String comma = '，';
                if(value.contains(comma)){
                    value = value.replaceAll(comma, '');
                }
                result = value;
            }
        }
        system.debug(result);
        return result;
    }
}