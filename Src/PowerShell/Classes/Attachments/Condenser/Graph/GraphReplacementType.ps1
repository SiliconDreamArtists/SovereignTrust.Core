# TODO (Post-MVP): Replace raw string ReplacementType handling with static GraphReplacementType class and JSON resolver for safer, typo-proof mappings.

$Global:GraphReplacementType = @{
    Unspecified = 0
    XmlTag      = 1    # <var />
    Attag       = 2    # @var
    AtAttag     = 4    # @@var
    Hashtag     = 8    # #var
    HashHashtag = 16   # ##var
    DollarParen = 32   # $(var)
    CurlyBrace  = 64   # {var}
}

$Global:GraphReplacementTypeReverse = @{
    0   = "Unspecified"
    1   = "XmlTag"
    2   = "Attag"
    4   = "AtAttag"
    8   = "Hashtag"
    16  = "HashHashtag"
    32  = "DollarParen"
    64  = "CurlyBrace"
}