#!/bin/bash

#words=("dá" "pás" "mês" "só" "pós" "fé" "trás" "ca-ra-jás" "ca-fé" "in-vés" "pa-ra-béns" "po-rém" "pa-péis" "cha-péu" "I-lhéus" "rou-xi-nóis" "tui-ui-ú" "teiús" "jú-ri" "jú-ris" "ví-rus" "ca-rá-ter" "têx-til" "tó-rax" "hí-fen" "fó-rum" "fó-runs" "ór-gão" "ór-gãos" "í-mã" "í-mãs" "bí-ceps" "pró-ton" "pró-tons" "á-geis" "i-mun-dí-ci-e" "lí-rio" "tú-neis" "tê-nue" "jó-quei" "nó-doa" "ce-ri-mô-nia" "his-tó-ria" "lú-ci-do" "sé-cu-lo" "pró-xi-mo" "he-ro-í-na" "ca-fe-í-na" "ju-í-zo" "fa-ís-ca" "con-traí-la" "Gra-jaú" "aí" "raí-zes")
#printf "%s\n" "${words[@]}" |

V="[aeiouáéíóúàèãõâêô]"; # vowels
UV="[aeiou]"; # unstressed vowels 
SV="[áéíóúàèãõâêô]"; # stressed vowels

patterns=(
    #"^(?!.*-).* 0$" # monosyllables no accent
    "^(?!.*-).*[aáàãeéêoóô]s? 1$" # monosyllables with accent
    # stressed monosyllables ending in 'a/as', 'e/es', 'o/os': as in words like 'dá', 'pás', 'mês', 'só', 'pós', 'fé', 'trás'.
    "^(?=(.*-){1,}).*([áãéêóô]s?|é[iumn]s?|óis?|ães?|ãos?|ões) 1$" # oxytone
    # Oxytones ending in 'a/as', 'e/es', 'o/os', 'em/ens' have accent: as in words like 'carajás', 'café', 'invés', 'parabéns', 'porém'.
    # Regex: [áãéêóô]s?$
    # e.g. á: es-tá, há, já, pa-na-má, ca-be-rá
    #      ã: lã, i-rã, ma-çã, ci-da-dâ, hor-te-lã
    #      é: fé, jo-sé, ca-fé, tau-ba-té, ro-da-pé
    #      ê: vo-cê, vê, quê, lê, crê, dos-si-ê, car-nê
    #      ó: nó, for-ró, a-vó, ja-có, qui-pro-có
    #      ô: me-trô, pi-vô, a-lô, a-vô, ca-me-lô
    #
    # Oxytones ending in open tonic diphthongs 'éi', 'éu', 'ói' receive an acute accent: as in words like 'papéis', 'chapéu', 'Ilhéus', 'rouxinóis'.
    # Regex: é[iu]s?$|óis?$
    # e.g. éi: pas-téis, ho-téis, a-néis, pin-céis
    #      éu: céu, cha-péu, tro-féu, réu, mau-so-léu
    #      ói: he-rói, do-dói, cau-bói
    #
    # In oxytones, the tonic vowels 'i' and 'u,' both in their regular forms and their plural forms ('is' and 'us'), 
    # receive an acute accent when they appear after a diphthong. For example: 'tuiuiú' and 'teiús'.
    # Regex: $UV{2}-[íú]s?$
    # e.g. VV-í: pi-au-í, i-ta-gua-í, qui-u-í, ta-man-du-a-í
    #      VV-ú: guai-ú, tei-ú
    #      exception: tu.i:u.i:ú (tu-iu-iú)
    #
    # Checking in the dictionary other oxytones that have accent:
    # UV="[aeiou]"; SV="[áéíóúàèãõâêô]"; grep -P "\-[a-z]*${SV}[a-z]s?$" <(cat ../data/hyphenations_6.dic ../data/hyphenations_5.dic) | rev | cut -d'-' -f1 | rev | grep -Pv "[áãéêóô]s?$|é[iu]s?|óis?$|$UV{2}-[íú]s?$" | sort | uniq -c | column
    # Ending with 
    #   - 'ão' or 'ões' 
    #   Regex: ãos?$|ões$ 
    #   e.g. não, inflação
    #   - 'ém' or 'éns' 
    #   Regex: é[mn]s?$ 
    #   e.g. também, parabéns
    #   - 'ãe' or 'ães' 
    #   Regex: ães?$ 
    #   e.g. mãe, alemães, pães
    #   P.S. There are no word ending in 'ao', 'oes', 'ae' or 'aes' in Portuguese, except proper nouns or foreignness.
    #        Examples: 'Bilbao' (which is named Bilbau in Portuguese), 'Dánao' or 'Dânao' (king of Libya in Greek mythology),
    #        'sebrae', 'reggae', 'sundae', 'moraes', 'paes', 'novaes'.
    #
    "^(?=(.*-){1,}).*(is?|u[mn]?s?|[rlxn]|ão?s?|[oa]ns?|ps|([aeiou])(?!=\1)[aeiou]s?) 2$" # paroxytone
    # old version: "^(?=(.*-){1,}).*([aio]s?|u[mn]?s?|[ao][mn]s?|[rlxn]|ão?s?|ps|[aeo]is?|[ui][iu]s?|i[aeou]s?|u[aoe]s?) 2$" # paroxytone 
    # still need check: ([ao]s?|[ao][m]s?|[aeo]is?|[ui][iu]s?|i[aeou]s?|u[aoe]s?)
    # rules included: is?|u[mn]?s?|[rlxn]|ão?s?|[oa]ns?|ps$
    # 
    # Paroxytones ending with 'i(s)' have accents, such as 'júri(s)'.
    # Regex: is?$
    # e.g. i: jú-ri, tá-xi, bi-quí,ni, sa-fá-ri, mar-tí-ni
    #      is: jú-ris, tê-nis, grá-tis, lá-pis, o-á-sis
    #
    # Paroxytone ending with 'us', 'um' or 'uns' have accent, such as 'vírus', 'fórum', 'fóruns'.
    # Regex: u[mn]?s?$
    # e.g. us: ví-rus, bô-nus, vê-nus, hú-mus, fí-cus
    #      um: fó-rum, ál-bum, quó-rum, té-tum
    #      uns: fó-runs, ál-buns
    #
    # Paroxytone ending with 'r', 'l', 'x', 'n' have accent, such as 'caráter', 'têxtil', 'tórax', 'hífen' (hifens has no accent)
    # Regex: [rlxn]$
    # e.g. r: dó-lar, lí-der, cé-sar, ca-rá-ter, cân-cer, a-çú-car
    #      l: pos-sí-vel, di-fí-cil, res-pon-sá-vel, ní-vel, fá-cil
    #      x: tó-rax, clí-max, lá-tex, fê-nix, dú-plex, có-dex
    #      n: ab-dô-men, có-lon, pó-len, é-den, glú-ten, né-on, hí-fen
    #
    # Paroxytone ending with 'ão(s)', 'ã(s)' have accent, such as 'órgão(s)', 'ímã(s)'.
    # Regex: ão?s?$
    # e.g. ã/ãs: ór-fã, í-mã, dól-mã
    #      ão/ãos: ór-gão, bên-ção, ór-fão, acór-dão, só-tão, o-ré-gão
    #
    # Paroxytone ending with 'on(s)', 'an(s)' have accent, such as 'próton(s)', 'écran(s)'.
    # Regex: [oa]ns?$
    # e.g. on/ons: pró-ton, có-lon, né-on, fó-ton, plânc-ton, có-don, í-on
    #      an/ans: pé-an, é-cran
    # P.S. Words ending in 'an(s)' are rare. It seems they might follow the same rule as those ending with 'on(s)', therefore they were added to the rule here.
    #
    # Paroxytone ending with 'ps' have accent, such as 'bíceps'.
    # Regex: ps$
    # e.g. ps: bí-ceps, fór-ceps, trí-ceps, qua-drí-ceps
    #
    # Paroxytone ending with oral diphthongs have accent, such as 'ágeis', 'imundície', 'lírio', 'túneis', 'tênue', 'jóquei', 'nódoa', 'cerimônia', 'história'.
    # Regex: ([aeiou])(?!=\1)[aeiou]s?$
    #
    # $ grep -P "[ie]-[gq]u[ao]$" <(cat ../data/hyphenations_6.dic ../data/hyphenations_5.dic ../data/hyphenations_4.dic) 
    # sí-li-qua
    # > regra: palavra terminada em [ie]-[gq]u[ao]$ não existe, deve ter acento [íé]-[gq]u[ao]$
    # $ grep -P "[íé]-[gq]u[ao]$" <(cat ../data/hyphenations_6.dic ../data/hyphenations_5.dic ../data/hyphenations_4.dic) | sed ':a;N;$!ba;s/\n/, /g'
    # é-gua, ré-gua, o-blí-quo, i-ní-quo, con-tí-guo, lé-gua, é-quo, tré-gua, am-bí-guo, e-xí-guo, o-blí-qua, u-bí-quo
    "^(?=(.*-){1,}).*([éáó]i|éu)-([a-z]+) 2$" # paroxytone with open diphthong: ei and oi
    # Those accents are no longer allowed after Portuguese Language Orthographic Agreement of 1990.
    # They are included to accept old written form.
    #
    # Regex: [éó]i-[a-z]+$
    # e.g. i-déi-a, es-tréi-a, as-sem-bléi-a, pla-téi-a, pro-téi-co, nu-cléi-co
    #      a-pói-a, pa-ra-nói-a, ta-blói-de, he-rói-co, as-te-rói-de, des-trói-er
    #
    # Although 'eu' and 'ai' are also open diphthong, there is no record of paroxytone word with accent on them. Anyway they are predicted by the rule here.
    #
    "^(?=(.*-){1,}).*(ê-em) 2$" # paroxytone ending with 'ê-em' such as 'lêem', 'crêem', 'vêem'.
    # Those accents are no longer allowed after Portuguese Language Orthographic Agreement of 1990.
    # Plural of verb such as 'crer', 'dar', 'ler', 'ver' no longer have accent: 'creem', 'deem', 'leem', 'descreem', 'releem', 'reveem'.
    #
    # Regex: ê-em$
    # e.g. vê-em, dê-em, lê-em, crê-em 
    #
    "^(?=(.*-){2,}).*$SV[a-z]*-[^-]+-[^-]+ 3$" # proparoxytone
    # All proparoxytone words (words with the stress on the third-to-last syllable) in Portuguese have diacritics placed over vowels to mark where the stress falls in the word.
    # Regex: $SV[a-z]*-[^-]+-[^-]+$
    #
    # e.g. po-lí-ti-ca, téc-ni-co, pú-bli-co, pe-rí-o-do, e-co-nô-mi-co, mú-si-ca 
    #
    #"^([^íú]+-)?[íú]s?(-.*|\s)\d$" # hiatus with í or ú: heroína, cafeína, juízo, faísca, contraí-la, Grajaú, aí, raízes.
    "$UV-[íú]s?(?!-?nh)(-.*|\s)\d$" # hiatus with í or ú: heroína, cafeína, juízo, faísca, contraí-la, Grajaú, aí, raízes.
    # The letters 'i' or 'u' receive an acute accent when they are stressed and appear as the second vowel in an hiatus.
    # Regex: $UV-[íú]s?($|-)
    # e.g. pa-ís, da-í, sa-ú-de, ju-í-zo, su-í-ça, ve-í-cu-lo
    #
    # However, there are exceptions: when the stressed 'i' or 'u' form a syllable with the following letter 'l', 'm', 'n', 'r' or 'z' (as in words like 'adail,' 'ruim,' 'contribuinte,' 'retribuirdes,' 'raiz'), or when they are followed by 'nh' (as in words like 'rainha' and 'moinho').
    # Regex: $UV-[íú]s?(?!-?nh)($|-)  
    #  - Adding a negative lookahead assertion to ensure that the sequence is not followed by an optional hyphen and then 'nh'.
    # The condition "following by 'l', 'm', 'n', 'r' or 'z'" is not added since those words would not have an hyphen after the 'i' or 'u', forming an hiatus.  
    #
    # superproparoxytone? ge-nu-i-na-men-te, re-i-nau-gu-ra-ção, de-ca-i-men-to
    )

vowel="[aeiouáéíóúàèãõâêô]";
V="[aeiou]";
VA="[áéíóúàèãõâêô]";

#awk -F\- '
#    /[áéíóúãõâêôàèìòùÁÉÍÓÚÃÕÂÊÔÀÈÌÒÙ]+/{ 
#    n = split($0, syllables, "-");
#    for (i = 1; i <= n; i++) { if (match(syllables[i],/[áéíóúãõâêôàèìòùÁÉÍÓÚÃÕÂÊÔÀÈÌÒÙ]+/)) {print $0,n-i; break;} } 
#    }
#' "${1:-/dev/stdin}" |
./accentposition.awk "${1:-/dev/stdin}" |
    while read line;
    do
	for pattern in "${patterns[@]}"; do
	    if grep -qP "$pattern" <<< "$line"; then
		hyphen=$(cut -d' ' -f1 <<< "$line")
		word=${hyphen//-/}
		pos=$(cut -d' ' -f2 <<< "$line")
		echo "$hyphen"
		#if grep -Pq "${vowel}{2,}" <(echo "$word"); then 
		#    # check hyphenation when we have vowel encounter
		#    if grep -Pq "${V}-${VA}s?$|${V}-ãs?$|${V}-ões$" <(echo "$hyphen"); then
		#	# when the final vowel of the vowel encounter has accent, it is an hiatus
		#	# e.g. in-dai-á; pre-á
		#	# the same applies for final vowel encounter ending with ã(s), ões
		#	# e.g. pe-ã; su-ti-ã; a-vi-ão; a-vi-ões; bas-ti-ão; bas-ti-ões
		#	echo "$hyphen"
		#    fi
		#else
		#    echo "$hyphen"
		#fi
		break
	    fi
	done
    done

#    tee \
#    >(grep -P '^(?!.*-).*[aáeéêoóô]s?')\
#    >(grep -P '^(?=(.*-){1,}).*([áãéêóô]s?|é[iumn]s?|óis?|ão|ões) 1$')\
#    >(grep -P '^(?=(.*-){1,}).*([i]s?|u[mn]?s?|o[mn]s?|[rlxn]|ão?s?|ps|[aeou][iu]s?|i[eu]s?) 2$')\
#    >(grep -P '^(?=(.*-){2,}).* 3$')\
#    >(grep -P '^([^íú]+-)?[íú]s?(-.*|\s)\d$') > /dev/null

# sort ../data/hyphenations_5.dic > /tmp/sdic
# ./checkaccents.sh /tmp/sdic | sort | cut -d' ' -f1 > /tmp/sdicca
# diff /tmp/sdic /tmp/sdicca | grep "[áéíóúãõâêôàèìòùÁÉÍÓÚÃÕÂÊÔÀÈÌÒÙ]" | more 


# Monossílabas
#   Acentuam-se os vocábulos monossílabos tônicos terminados em a/as, e/es,
#   o/os: dá, pás, mês, só, pós, fé, trás
#
# Oxítonas
#   As palavras oxítonas que terminam em a/as, e/es, o/os, em/ens são
#   acentuadas: carajás, café, invés, parabéns, porém.  As oxítonas que
#   terminam com os ditongos tônicos abertos éi, éu, ói recebem acento agudo:
#   papéis, chapéu, Ilhéus, rouxinóis.  Nas palavras oxítonas, as vogais
#   tônicas i(s) e u(s) levam acento agudo quando estiverem depois de um
#   ditongo: tuiuiú, teiús.
# 
# Paroxítonas
#   São acentuadas as paroxítonas (aquelas cuja sílaba tônica é a penúltima)
#   terminadas em i/is, us, r, l, x, n, um/uns, ão/ãos, ã/ãs, ps, on/ons:
#   júri/júris, vírus, caráter, têxtil, tórax, hífen (hifens não tem acento),
#   fórum/fóruns, órgão/órgãos, ímã/ímãs, bíceps, próton/prótons.  Nas palavras
#   paroxítonas terminadas em ditongo oral (ai, ei, oi, ui, ia, ie, io, iu, au, eu, ou, iu)
#   acentua-se a vogal da sílaba tônica: ágeis, imundície, lírio, túneis, tênue, 
#   jóquei, nódoa, cerimônia, história. Antes do acordo ortográfico, paroxítonas terminadas 
#   em vogais “a” e “o” também eram acentuadas. Exemplos: idéia, heróico, assembléia.
# 
# Proparoxítonas
#   Todas as palavras proparoxítonas (aquelas cuja sílaba tônica é a
#   antepenúltima) são acentuadas: lúcido, século, próximo.
#
# Acentuação das letras i e u
#
#   De modo geral, as letras i ou u, quando tônicas, recebem acento quando são
#   a segunda vogal de um hiato: heroína, cafeína, juízo, faísca, contraí-la,
#   Grajaú, aí, raízes.
