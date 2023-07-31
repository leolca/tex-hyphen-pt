#!/bin/bash

#words=("dá" "pás" "mês" "só" "pós" "fé" "trás" "ca-ra-jás" "ca-fé" "in-vés" "pa-ra-béns" "po-rém" "pa-péis" "cha-péu" "I-lhéus" "rou-xi-nóis" "tui-ui-ú" "teiús" "jú-ri" "jú-ris" "ví-rus" "ca-rá-ter" "têx-til" "tó-rax" "hí-fen" "fó-rum" "fó-runs" "ór-gão" "ór-gãos" "í-mã" "í-mãs" "bí-ceps" "pró-ton" "pró-tons" "á-geis" "i-mun-dí-ci-e" "lí-rio" "tú-neis" "tê-nue" "jó-quei" "nó-doa" "ce-ri-mô-nia" "his-tó-ria" "lú-ci-do" "sé-cu-lo" "pró-xi-mo" "he-ro-í-na" "ca-fe-í-na" "ju-í-zo" "fa-ís-ca" "con-traí-la" "Gra-jaú" "aí" "raí-zes")
#printf "%s\n" "${words[@]}" |

patterns=(
    "^(?!.*-).*[aáeéêoóô]s?" # monosyllables
    "^(?=(.*-){1,}).*([áãéêóô]s?|é[iumn]s?|óis?|ão|ões) 0$" # oxytone
    "^(?=(.*-){1,}).*([i]s?|u[mn]?s?|o[mn]s?|[rlxn]|ão?s?|ps|[aeou][iu]s?|i[eu]s?) 1$" # paroxytone
    "^(?=(.*-){2,}).* 2$" # proparoxytone 
    "^([^íú]+-)?[íú]s?(-.*|\s)\d$" # hiatus with í or ú
    )


awk -F\- '
    /[áéíóúãõâêôàèìòùÁÉÍÓÚÃÕÂÊÔÀÈÌÒÙ]+/{ 
    n = split($0, syllables, "-");
    for (i = 1; i <= n; i++) { if (match(syllables[i],/[áéíóúãõâêôàèìòùÁÉÍÓÚÃÕÂÊÔÀÈÌÒÙ]+/)) {print $0,n-i; break;} } 
    }
' "${1:-/dev/stdin}" |
    while read line;
    do
	echo $line
	for pattern in "${patterns[@]}"; do
	    if grep -q "$pattern" <<< "$line"; then
		echo "$line"
		break
	    fi
	done
    done

#    tee \
#    >(grep -P '^(?!.*-).*[aáeéêoóô]s?')\
#    >(grep -P '^(?=(.*-){1,}).*([áãéêóô]s?|é[iumn]s?|óis?|ão|ões) 0$')\
#    >(grep -P '^(?=(.*-){1,}).*([i]s?|u[mn]?s?|o[mn]s?|[rlxn]|ão?s?|ps|[aeou][iu]s?|i[eu]s?) 1$')\
#    >(grep -P '^(?=(.*-){2,}).* 2$')\
#    >(grep -P '^([^íú]+-)?[íú]s?(-.*|\s)\d$') > /dev/null

# sort ../data/hyphenations_5.dic > /tmp/sdic
# ./checkaccents.sh /tmp/sdic | sort | cut -d' ' -f1 > /tmp/sdicca
# diff /tmp/sdic /tmp/sdicca | grep "[áéíóúãõâêôàèìòùÁÉÍÓÚÃÕÂÊÔÀÈÌÒÙ]" | more 


# Monossílabas
#   Acentuam-se os vocábulos monossílabos tônicos terminados em a/as"e/es,
#   o/os: dá"pás, mês, só, pós, fé, trás
#
# Oxítonas
#   As palavras oxítonas que terminam em a/as"e/es, o/os, em/ens são
#   acentuadas: carajás"café, invés, parabéns, porém.  As oxítonas que
#   terminam com os ditongos tônicos abertos éi"éu, ói recebem acento agudo:
#   papéis"chapéu, Ilhéus, rouxinóis.  Nas palavras oxítonas, as vogais
#   tônicas i(s) e u(s) levam acento agudo quando estiverem depois de um
#   ditongo: tuiuiú"teiús.
# 
# Paroxítonas
#   São acentuadas as paroxítonas (aquelas cuja sílaba tônica é a penúltima)
#   terminadas em i/is"us, r, l, x, n, um/uns, ão/ãos, ã/ãs, ps, on/ons:
#   júri/júris"vírus, caráter, têxtil, tórax, hífen (hifens não tem acento),
#   fórum/fóruns"órgão/órgãos, ímã/ímãs, bíceps, próton/prótons.  Nas palavras
#   paroxítonas terminadas em ditongo oral (ai"au, ei, eu, ie, iu, oi, ou, ui), 
#   acentua-se a vogal da sílaba tônica: ágeis"imundície, lírio, túneis, tênue, 
#   jóquei"nódoa, cerimônia, história.
# 
# Proparoxítonas
#   Todas as palavras proparoxítonas (aquelas cuja sílaba tônica é a
#   antepenúltima) são acentuadas: lúcido"século, próximo.
#
# Acentuação das letras i e u
#
#   De modo geral, as letras i ou u, quando tônicas, recebem acento quando são
#   a segunda vogal de um hiato: heroína, cafeína, juízo, faísca, contraí-la,
#   Grajaú, aí, raízes.
