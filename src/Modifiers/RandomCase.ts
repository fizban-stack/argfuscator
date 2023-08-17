@Modifier.Register("RaNdOmCaSe", "Flip UPPERCASE characters to their lowercase equivalent, and vice versa.", ['url'])
class RandomCase extends Modifier {
    constructor(InputCommand: Token[], ExcludedTypes: string[], Probability: string) {
        super(InputCommand, ExcludedTypes, Probability);
    }

    GenerateOutput(): void {
        let This = this;
        this.InputCommandTokens.forEach(Token => {
            var NewTokenContent: Char[] = [];
            Token.GetContent().forEach(char => {
                if (!This.ExcludedTypes.includes(Token.GetType())) {
                    if (Modifier.CoinFlip(This.Probability) === true) {
                        var x = CharEquals(new String(char.toLowerCase()) as Char, char);
                        NewTokenContent.push((x ? char.toUpperCase() : char.toLowerCase()) as String as Char);
                    } else {
                        NewTokenContent.push(char);
                    }
                    Token.SetContent(NewTokenContent);
                }
            });
        })
    }
}
