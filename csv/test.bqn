⟨CSV⟩←•Import"./csv.bqn"

!⟨⟨"a","b"⟩,⟨"c","d","e"⟩,⟨"f","g","h","i"⟩
⟩≡ CSV "a,b
c,d,e
f,g,h,i"

!⟨⟨"first","last","address","city","zip"⟩
 ⟨"John","Doe","120 any st.","Anytown, WW","08123"⟩
⟩≡ CSV "first,last,address,city,zip
John,Doe,120 any st.,""Anytown, WW"",08123"

!⟨⟨"a","b","c"⟩,⟨"1",⟨⟩,⟨⟩⟩,⟨"2","3","4"⟩
⟩≡ CSV "a,b,c
1,"""",""""
2,3,4"

!⟨⟨"a","b"⟩,⟨"1","ha ""ha"" ha"⟩,⟨"3","4"⟩
⟩≡ CSV "a,b
1,""ha """"ha"""" ha""
3,4"

!⟨⟨"key","val"⟩,⟨"1","{""type"": ""Point"", ""coordinates"": [102.0, 0.5]}"⟩
⟩≡ CSV"key,val
1,""{""""type"""": """"Point"""", """"coordinates"""": [102.0, 0.5]}"""

!⟨⟨"a","b"⟩,⟨"1","ha
""ha""
ha"⟩,⟨"3","4"⟩
⟩≡ CSV "a,b
1,""ha
""""ha""""
ha""
3,4"
