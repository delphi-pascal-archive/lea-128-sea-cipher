
{    Date : 05/06/2009 13:29:37
  Modifié par Cirec pour assurer la compatibilité avec unicode de Delphi2009                                  }
(*

Algorithme LEA-128 (Lossy Elimination Algorithm - Algorithme de perte de données par élimination).
Auteur : Bacterius.



Algorithme de perte de données par élimination : on élimine la donnée et on en tire son empreinte.
Effectivement, cet algorithme va réduire une donnée de taille variable (de 1 octet, 12 mégas, ou même
1 gigaoctet) en sa représentation unique (de taille fixe : 16 octets). Chaque donnée aura une
représentation unique (théoriquement : mais en pratique, il y aura toujours des collisions, car il
y a plus de possibilités de messages que de possibilités de hash : d'après le principe des tiroirs).
Mathématiquement, si Hash(x) est la fonction par laquelle passe la donnée x, et H le hash de cette
donnée x, on a :

y <> x
Hash(x) = H
Hash(y) <> H

Cet algorithme de hachage est basé sur un hachage par blocs de 512 bits, c'est à dire
que à chaque bloc de 512 bits, un certain nombre d'opérations va s'effectuer. Voici un schéma :
________________________________________________________________________________


VALEURS DE DEPART  | MESSAGE
                   |
   A  B  C  D      |
   |  |  |  |      |
   ?  ?  ?  ?  <---- PREMIER BLOC 512 BITS DU MESSAGE (altération de A, B, C, D)
   |  |  |  |      |
   ?  ?  ?  ?  <---- SECOND BLOC 512 BITS DU MESSAGE (altération de A, B, C, D)
   |  |  |  |      |
   ?  ?  ?  ?  <---- TROISIEME BLOC 512 BITS DU MESSAGE (altération de A, B, C, D)
   |  |  |  |      |
   ................. etc ...
   |  |  |  |      |
   W  X  Y  Z  <---- HACHAGES (altérés)
   \  |  |  /      |
    Hachage    <---- de 128 bits, c'est la réunion de W, X, Y et Z (32 bits chacun)

________________________________________________________________________________

Remarque : si la taille du message de départ n'est pas multiple de 64 octets (512 bits),
un dépassement de buffer pourrait survenir. C'est pourquoi l'on a introduit la notion
de remplissage ou "padding", qui est appliqué même si la taille du message est multiple
de 64 octets. Cela consiste à ajouter un bit à 1 à la fin du message, suivi par autant de
bits à 0 que nécessaire. Exemple pour un message de 3 octets :

110111011001011101101110 ... 10000000
Octet 1|Octet 2|Octet 3| ... Padding|

L'algorithme de hachage tient surtout à la façon dont sont altérées les valeurs
A, B, C et D à chaque double mot du message.
HashTable contient les 4 valeurs de départ. Elles représentent la "signature"
de l'algorithme. Si vous changez ces valeurs, les hachages changeront
également.
HashTransform permet un effet d'avalanche (gros changements du hash pour petite modification
du message) plus rapide. Si vous changez une ou plusieurs de ces valeurs, tous les hachages
seront différents.
Cet algorithme est assez rapide, et le test de collisions n'est pas terminé.
Comme pour tous les algorithmes de hash, on s'efforce de faire des hachages les
moins similaires possibles pour des petits changements. Essayez avec "a", puis "A",
puis "b", vous verrez !

¤ Les fonctions
- Hash : cette fonction effectue le hachage d'une donnée Buffer, de taille Size.
         Il s'agit de la fonction de base pour hacher un message.
- HashToString : cette fonction convertit un hachage en une chaîne lisible.
- StringToHash : cette fonction convertit une chaîne lisible en hash, si celle-ci
                 peut correspondre à un hash. En cas d'erreur, toutes les valeurs
                 du hash sont nulles.
- SameHash     : cette fonction compare deux hachages et dit si celles-ci sont identiques.
                 Renvoie True le cas échéant, False sinon.
- HashCrypt : cette fonction crypte un hachage tout en conservant son aspect.
- HashUncrypt : cette fonction décrypte un hachage crypté avec la bonne clef.
- IsHash : cette fonction vérifie si la chaîne passée peut être ou est un hachage.
- HashStr : cette fonction effectue le hachage d'une chaîne de caractères.
- HashInt : cette fonction effectue le hachage d'un entier sur 32 bits.
            Attention : la fonction effectue le hachage de l'entier directement,
            elle ne convertit absolument pas l'entier en texte !
- HashFile : cette fonction effectue le hachage du contenu d'un fichier.

¤ Collisions.
Dans tout algorithme de hachage existent des collisions. Cela découle logiquement
de l'affirmation suivante :
Il y a un nombre limité de hachages possibles (2^128). Mais il existe une infinité
de messages possibles, si l'on ne limite pas les caractères.
Cependant, l'algorithme peut réduire le nombre de collisions, qui, théoriquement
infini, ne l'est pas à l'échelle humaine. Si l'on suppose qu'à l'échelle humaine,
nous ne tenons compte, schématiquement, de messages de 10 octets maximum (c'est
un exemple), l'on a une possibilité de combinaisons de 255^10 octets, sur une
possibilité de 2^128 hachages. Il est donc possible de n'avoir aucune collision,
puisqu'il y a plus de possibilités de hachages que de possibilités de combinaisons.

¤ Protection additionnelle
Un hash est déjà théoriquement impossible à inverser. Cependant, cela est possible
à l'échelle mondiale avec un réseau de super-calculateurs, moyennant tout de même
une quantité de temps impressionnante (avec les 80 et quelques supercalculateurs
de IBM, l'on ne met que 84 ans à trouver le message (de 10 caractères) correspondant
au hachage). Vous pouvez donc ajouter des protections supplémentaires :
- Le salage : cela consiste à ajouter une donnée supplémentaire au message avant
  hachage. Cela rend le hachage moins vulnérable aux attaques par dictionnaire.
  Par exemple, si vous avez un mot de passe "chat", quand quelqu'un va attaquer
  le hachage de "chat", il va rapidement le trouver dans le dictionnaire, va
  s'apercevoir que le hachage est le même, et va déduire qu'il s'agit de votre
  mot de passe. Pour éviter ça, vous allez ajouter une donnée moins évidente au
  message, disons "QS77". Vous allez donc hacher le mot de passe "QS77chat"
  ( ou "chatQS77"). Ce mot ne figure evidemment pas dans le dictionnaire.
  Le pirate va donc avoir un problème, et va alors eventuellement laisser tomber,
  ou bien changer de technique, et attaquer par force brute (tester toutes les
  combinaisons possibles). Si vous avez un mot de passe de 5 caractères ASCII, cela
  lui prendra au plus 5 jours. Si vous avez un mot de passe de 10 caractères,
  cela mettra 70 milliards d'années. Donc, optez pour un mot de passe d'au
  moins 6 caractères (et eventuellement, rajoutez un caractère spécial, comme
  un guillemet, pour forcer le pirate à attaquer en ASCII et non pas en
  alphanumérique (il lui faudrait plus de temps de tester les 255 caractères ASCII
  que seulement les 26 lettres de l'alphabet et les nombres ...)).
- Le cryptage : cela consiste à crypter le hachage par-dessus (tout en lui faisant garder
  son aspect de hachage ! Par exemple, si vous avez un hachage "A47F", n'allez
  pas le crypter en "%E#!", il apparaîtrait evident qu'il est crypté !).
  Cela a pour effet de compliquer encore plus le travail du pirate, qui,
  inconsciemment, sera en train d'essayer de percer un mauvais hachage !
  Si le cryptage est bien réalisé, il peut s'avérer plus qu'efficace. Cependant,
  pensez à conserver la clef de cryptage/décryptage, sans quoi, si pour une raison
  ou pour une autre vous aviez à récupérer le hash d'origine (cela peut arriver parfois),
  vous devriez tester toutes les clefs ...
  Une fonction de cryptage et une de décryptage est fournie dans cette unité.
- Le byteswap : cela consiste à "swapper" les octets du hachage. Cela revient à
  crypter le hachage puisque cette opération est réversible "permutative" (la
  fonction de cryptage joue également le rôle de la fonction de décryptage).

Ajouter une petite protection ne coûte rien de votre côté, et permet de se protéger
plus qu'efficacement contre des attaques. Même si un hash en lui-même est déjà pas
mal, mieux vaut trop que pas assez !

¤ Autres utilités du hash
- générateur de nombres aléatoires : l'algorithme de hachage est si particulier
pour le MD5 par exemple, qu'il a été déclaré comme efficace en tant que générateur
de nombres pseudo-aléatoires, et il a passé avec succès tous les tests statistiques.
L'algorithme LEA n'est pas garanti d'être efficace comme générateur de nombres
pseudo-aléatoires.

} *)

unit LEA_Hash;

interface

uses Windows, SysUtils, Dialogs;

const
  { Ces valeurs sont pseudo-aléatoires (voir plus bas) et sont distinctes (pas de doublon) }
  { Notez que le hachage d'une donnée nulle (de taille 0) renverra HashTable (aucune altération) }
  HashTable: array [$0..$3] of Longword = ($CF306227, $4FCE8AC8, $ACE059ED, $4E3079A6);
  { MODIFIER CES VALEURS ENTRAINERA UNE MODIFICATION DE TOUS LES HACHAGES }

type
  THash = record          { La structure d'un hash LEA sur 128 bits }
   A, B, C, D: Longword;  { Les quatre double mots                  }
  end;

  TLEACallback = procedure (BlockIndex: Longword; BlockCount: Longword); stdcall;

function Hash         (const Buffer; const Size: Longword; Callback: TLEACallback = nil): THash;
function HashStr      (const Str     : AnsiString  ): THash;
function HashInt      (const Int     : Integer ): THash;
function HashFile     (const FilePath: String; Callback: TLEACallback = nil): THash;
function HashToString (const Hash    : THash   ): AnsiString;
function StringToHash (const Str     : AnsiString  ): THash;
function SameHash     (const A, B    : THash   ): Boolean;
function Same         (A, B: Pointer; SzA, SzB: Longword): Boolean;
function HashCrypt    (const Hash    : AnsiString;  Key: Longword): AnsiString;
function HashUncrypt  (const Hash    : AnsiString;  Key: Longword): AnsiString;
function IsHash       (const Hash    : AnsiString  ): Boolean;

implementation

const Power2: array [$1..$20] of Longword =($00000001, $00000002, $00000004, $00000008,
                                            $00000010, $00000020, $00000040, $00000080,
                                            $00000100, $00000200, $00000400, $00000800,
                                            $00001000, $00002000, $00004000, $00008000,
                                            $00010000, $00020000, $00040000, $00080000,
                                            $00100000, $00200000, $00400000, $00800000,
                                            $01000000, $02000000, $04000000, $08000000,
                                            $10000000, $20000000, $40000000, $80000000);

function RShl(A, B: Longword): Longword;
begin
 Result := (A shl B) or (B shl $20);
end;

type
 PLEABuf = ^TLEABuf;
 TLEABuf = array [$0..$F] of Longword;

procedure LEAInternal(var A, B, C, D: Longword; Buf: TLEABuf);
Var
 I: Integer;
begin
 for I := $1 to $F do { Pour chaque double mot du buffer }
  begin
   { On incrémente chaque valeur A, B, C et D, puis on l'altère }
   Inc(A, Buf[I] + (B or (C xor (not D))));
   A := ((A shl $6) xor (A shr $D)) + Buf[Pred(I)];
   Inc(B, Buf[I] + (C or (D xor (not A))));
   B := ((B shl $A) xor (B shr $5)) + Buf[Pred(I)];
   Inc(C, Buf[I] + (D or (A xor (not B))));
   C := ((C shl $3) xor (C shr $C)) + Buf[Pred(I)];
   Inc(D, Buf[I] + (A or (B xor (not C))));
   D := ((D shl $E) xor (D shr $9)) + Buf[Pred(I)];
  end;
end;

function Hash(const Buffer; const Size: Longword; Callback: TLEACallback = nil): THash;
Var
 V: PLEABuf;
 Sz, Cnt: Longword;
 Buf: TLEABuf;
 E: Pointer;
 BlockCount: Longword;
begin
 { On récupère les valeurs du tableau }
 Move(HashTable, Result, $10);

 { Si buffer vide, on a les valeurs initiales }
 if Size = $0 then Exit;

 { On calcule le padding }
 Cnt := $0;
 Sz := Size;
 repeat Inc(Sz) until Sz mod $40 = $0;

 { On calcule le nombre de blocs }
 BlockCount := Sz div $40;

 { On prend le début du buffer }
 V := @Buffer;
 { On calcule la fin du buffer }
 E := Ptr(Longword(@Buffer) + Sz);

 with Result do
  repeat { Pour chaque double mot du message, tant qu'on est pas arrivé à la fin ... }
   begin
    ZeroMemory(@Buf, $40);
    if Size - Cnt > $3F then Move(V^, Buf, $40) else
     begin
      Move(V^, Buf, Size - Cnt);
      FillMemory(Ptr(Longword(@Buf) + Succ(Size - Cnt)), 1, $80);
     end;

    { On effectue une altération complexe }
    LEAInternal(A, B, C, D, Buf);

    { On appelle le callback }
    if Assigned(Callback) then Callback(Cnt div $40, BlockCount);


    Inc(V);  { On passe aux 512 bits suivants ! }
    Inc(Cnt, $40); { On incrémente ce qui a été fait }
    { Ne pas modifier les lignes de calcul, sinon cela peut ne plus marcher }
   end
  until V = E;
end;

function HashStr(const Str: AnsiString): THash;
begin
 { On va envoyer le pointeur sur la chaîne à la fonction Hash. }
 Result := Hash(PAnsiChar(Str)^, Length(Str));
end;

function HashInt(const Int: Integer): THash;
begin
 { On envoie directement le nombre dans le buffer. }
 Result := Hash(Int, SizeOf(Integer));
end;

function HashFile(const FilePath: String; Callback: TLEACallback = nil): THash;
Var
 H, M: Longword;
 P: Pointer;
begin
 { On va mettre à 0 pour cette fonction, car autant il n'était pas possible que les fonctions
   précédentes n'échouent, celle-ci peut échouer pour diverses raisons. }
 ZeroMemory(@Result, 16);

 { On ouvre le fichier }
 H := CreateFile(PChar(FilePath), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE,
                 nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN, 0);

 { Si erreur d'ouverture, on s'en va }
 if H = INVALID_HANDLE_VALUE then Exit;
 { CreateFileMapping rejette les fichiers de taille 0 : ainsi, on doit les tester avant }
 if GetFileSize(H, nil) = 0 then
  begin
   Result := Hash('', 0); { On récupère un hash nul }
   CloseHandle(H);        { On libère le handle }
   Exit;
  end;

 { On crée une image mémoire du fichier }
 try
  M := CreateFileMapping(H, nil, PAGE_READONLY, 0, 0, nil);
  try
   { On récupère un pointeur sur l'image du fichier en mémoire }
   if M = 0 then Exit;
   P := MapViewOfFile(M, FILE_MAP_READ, 0, 0, 0);
   try
    { On envoie le pointeur au hash, avec comme taille de buffer la taille du fichier }
    if P = nil then Exit;
    Result := Hash(P^, GetFileSize(H, nil), Callback);
   finally
   { On libère tout ... }
   UnmapViewOfFile(P);
   end;
  finally
   CloseHandle(M);
  end;
 finally
  CloseHandle(H);
 end;
end;

function HashToString(const Hash: THash): AnsiString;
begin
 { On ajoute les quatre entiers l'un après l'autre sous forme héxadécimale ... }
 Result := AnsiString(Format('%.8x%.8x%.8x%.8x', [Hash.A, Hash.B, Hash.C, Hash.D]));
end;

function StringToHash(const Str: AnsiString): THash;
begin
 if IsHash(Str) then
  with Result do
   begin
    { Astuce de Delphi : un HexToInt sans trop de problèmes ! Rajouter un "$" devant le nombre et
     appeller StrToInt. Cette astuce accepte un maximum de 8 caractères après le signe "$".      }
    A := StrToInt(Format('$%s', [Copy(Str, 1, 8)]));
    B := StrToInt(Format('$%s', [Copy(Str, 9, 8)]));
    C := StrToInt(Format('$%s', [Copy(Str, 17, 8)]));
    D := StrToInt(Format('$%s', [Copy(Str, 25, 8)]));
   end
 else ZeroMemory(@Result, 16); { Si Str n'est pas un hash, on met tout à 0 }
end;

function SameHash(const A, B: THash): Boolean;
begin
 { On compare les deux hashs ... }
 Result := CompareMem(@A, @B, 16);
end;

function Same(A, B: Pointer; SzA, SzB: Longword): Boolean;
begin
 { Cette fonction va regarder si deux objets mémoire (définis par leur pointeur de début
   et leur taille) sont identiques en comparant leur hash. }
 Result := SameHash(Hash(A, SzA), Hash(B, SzB));
end;

const
 Z = #0; { Le caractère nul, plus pratique de l'appeller Z que de faire chr(0) ou #0 }

function hxinc(X: AnsiChar): AnsiChar; { Incrémentation héxadécimale }
const
 XInc: array [48..70] of AnsiChar = ('1', '2', '3', '4', '5', '6', '7', '8', '9', 'A',
                                      Z, Z, Z, Z, Z, Z, Z, 'B', 'C', 'D', 'E', 'F', '0');
begin
 if ord(X) in [48..57, 65..70] then Result := XInc[ord(X)] else Result := Z;
end;

function hxdec(X: AnsiChar): AnsiChar; { Décrémentation héxadécimale ... }
const
 XDec: array [48..70] of AnsiChar = ('F', '0', '1', '2', '3', '4', '5', '6', '7', '8',
                                      Z, Z, Z, Z, Z, Z, Z, '9', 'A', 'B', 'C', 'D', 'E');
begin
 if ord(X) in [48..57, 65..70] then Result := XDec[ord(X)] else Result := Z;
end;

function HashCrypt(const Hash: AnsiString; Key: Longword): AnsiString;
Var
 I: Integer;
begin
 { Cryptage avec une clef binaire }
 Result := Hash;
 if not IsHash(Hash) then Exit;
 for I := 32 downto 1 do
  if Key and Power2[I] <> 0 then Result[I] := hxinc(Result[I]) else Result[I] := hxdec(Result[I]);
end;

function HashUncrypt(const Hash: AnsiString; Key: Longword): AnsiString;
Var
 I: Integer;
begin
 { Décryptage avec une clef binaire }
 Result := Hash;
 if not IsHash(Hash) then Exit;
 for I := 32 downto 1 do
  if Key and Power2[I] <> 0 then Result[I] := hxdec(Result[I]) else Result[I] := hxinc(Result[I]);
end;

function IsHash(const Hash: AnsiString): Boolean;
Var
 I: Integer;
begin
 { Vérification de la validité de la chaîne comme hash. }
 Result := False;
 if Length(Hash) <> 32 then Exit; { Si la taille est différente de 32, c'est déjà mort ... }
 { Si l'on rencontre un seul caractère qui ne soit pas dans les règles, on s'en va ... }
 {$ifndef unicode}
 for I := 1 to 32 do if not (Hash[I] in ['0'..'9', 'A'..'F', 'a'..'f']) then Exit;
 {$else}
 for I := 1 to 32 do if not CharInSet(Hash[I], ['0'..'9', 'A'..'F', 'a'..'f']) then Exit;
 {$endif}
 { Si la chaine a passé tous les tests, c'est bon ! }
 Result := True;
end;

end.
