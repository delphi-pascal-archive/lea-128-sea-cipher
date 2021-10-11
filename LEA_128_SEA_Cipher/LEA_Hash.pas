
{    Date : 05/06/2009 13:29:37
  Modifi� par Cirec pour assurer la compatibilit� avec unicode de Delphi2009                                  }
(*

Algorithme LEA-128 (Lossy Elimination Algorithm - Algorithme de perte de donn�es par �limination).
Auteur : Bacterius.



Algorithme de perte de donn�es par �limination : on �limine la donn�e et on en tire son empreinte.
Effectivement, cet algorithme va r�duire une donn�e de taille variable (de 1 octet, 12 m�gas, ou m�me
1 gigaoctet) en sa repr�sentation unique (de taille fixe : 16 octets). Chaque donn�e aura une
repr�sentation unique (th�oriquement : mais en pratique, il y aura toujours des collisions, car il
y a plus de possibilit�s de messages que de possibilit�s de hash : d'apr�s le principe des tiroirs).
Math�matiquement, si Hash(x) est la fonction par laquelle passe la donn�e x, et H le hash de cette
donn�e x, on a :

y <> x
Hash(x) = H
Hash(y) <> H

Cet algorithme de hachage est bas� sur un hachage par blocs de 512 bits, c'est � dire
que � chaque bloc de 512 bits, un certain nombre d'op�rations va s'effectuer. Voici un sch�ma :
________________________________________________________________________________


VALEURS DE DEPART  | MESSAGE
                   |
   A  B  C  D      |
   |  |  |  |      |
   ?  ?  ?  ?  <---- PREMIER BLOC 512 BITS DU MESSAGE (alt�ration de A, B, C, D)
   |  |  |  |      |
   ?  ?  ?  ?  <---- SECOND BLOC 512 BITS DU MESSAGE (alt�ration de A, B, C, D)
   |  |  |  |      |
   ?  ?  ?  ?  <---- TROISIEME BLOC 512 BITS DU MESSAGE (alt�ration de A, B, C, D)
   |  |  |  |      |
   ................. etc ...
   |  |  |  |      |
   W  X  Y  Z  <---- HACHAGES (alt�r�s)
   \  |  |  /      |
    Hachage    <---- de 128 bits, c'est la r�union de W, X, Y et Z (32 bits chacun)

________________________________________________________________________________

Remarque : si la taille du message de d�part n'est pas multiple de 64 octets (512 bits),
un d�passement de buffer pourrait survenir. C'est pourquoi l'on a introduit la notion
de remplissage ou "padding", qui est appliqu� m�me si la taille du message est multiple
de 64 octets. Cela consiste � ajouter un bit � 1 � la fin du message, suivi par autant de
bits � 0 que n�cessaire. Exemple pour un message de 3 octets :

110111011001011101101110 ... 10000000
Octet 1|Octet 2|Octet 3| ... Padding|

L'algorithme de hachage tient surtout � la fa�on dont sont alt�r�es les valeurs
A, B, C et D � chaque double mot du message.
HashTable contient les 4 valeurs de d�part. Elles repr�sentent la "signature"
de l'algorithme. Si vous changez ces valeurs, les hachages changeront
�galement.
HashTransform permet un effet d'avalanche (gros changements du hash pour petite modification
du message) plus rapide. Si vous changez une ou plusieurs de ces valeurs, tous les hachages
seront diff�rents.
Cet algorithme est assez rapide, et le test de collisions n'est pas termin�.
Comme pour tous les algorithmes de hash, on s'efforce de faire des hachages les
moins similaires possibles pour des petits changements. Essayez avec "a", puis "A",
puis "b", vous verrez !

� Les fonctions
- Hash : cette fonction effectue le hachage d'une donn�e Buffer, de taille Size.
         Il s'agit de la fonction de base pour hacher un message.
- HashToString : cette fonction convertit un hachage en une cha�ne lisible.
- StringToHash : cette fonction convertit une cha�ne lisible en hash, si celle-ci
                 peut correspondre � un hash. En cas d'erreur, toutes les valeurs
                 du hash sont nulles.
- SameHash     : cette fonction compare deux hachages et dit si celles-ci sont identiques.
                 Renvoie True le cas �ch�ant, False sinon.
- HashCrypt : cette fonction crypte un hachage tout en conservant son aspect.
- HashUncrypt : cette fonction d�crypte un hachage crypt� avec la bonne clef.
- IsHash : cette fonction v�rifie si la cha�ne pass�e peut �tre ou est un hachage.
- HashStr : cette fonction effectue le hachage d'une cha�ne de caract�res.
- HashInt : cette fonction effectue le hachage d'un entier sur 32 bits.
            Attention : la fonction effectue le hachage de l'entier directement,
            elle ne convertit absolument pas l'entier en texte !
- HashFile : cette fonction effectue le hachage du contenu d'un fichier.

� Collisions.
Dans tout algorithme de hachage existent des collisions. Cela d�coule logiquement
de l'affirmation suivante :
Il y a un nombre limit� de hachages possibles (2^128). Mais il existe une infinit�
de messages possibles, si l'on ne limite pas les caract�res.
Cependant, l'algorithme peut r�duire le nombre de collisions, qui, th�oriquement
infini, ne l'est pas � l'�chelle humaine. Si l'on suppose qu'� l'�chelle humaine,
nous ne tenons compte, sch�matiquement, de messages de 10 octets maximum (c'est
un exemple), l'on a une possibilit� de combinaisons de 255^10 octets, sur une
possibilit� de 2^128 hachages. Il est donc possible de n'avoir aucune collision,
puisqu'il y a plus de possibilit�s de hachages que de possibilit�s de combinaisons.

� Protection additionnelle
Un hash est d�j� th�oriquement impossible � inverser. Cependant, cela est possible
� l'�chelle mondiale avec un r�seau de super-calculateurs, moyennant tout de m�me
une quantit� de temps impressionnante (avec les 80 et quelques supercalculateurs
de IBM, l'on ne met que 84 ans � trouver le message (de 10 caract�res) correspondant
au hachage). Vous pouvez donc ajouter des protections suppl�mentaires :
- Le salage : cela consiste � ajouter une donn�e suppl�mentaire au message avant
  hachage. Cela rend le hachage moins vuln�rable aux attaques par dictionnaire.
  Par exemple, si vous avez un mot de passe "chat", quand quelqu'un va attaquer
  le hachage de "chat", il va rapidement le trouver dans le dictionnaire, va
  s'apercevoir que le hachage est le m�me, et va d�duire qu'il s'agit de votre
  mot de passe. Pour �viter �a, vous allez ajouter une donn�e moins �vidente au
  message, disons "QS77". Vous allez donc hacher le mot de passe "QS77chat"
  ( ou "chatQS77"). Ce mot ne figure evidemment pas dans le dictionnaire.
  Le pirate va donc avoir un probl�me, et va alors eventuellement laisser tomber,
  ou bien changer de technique, et attaquer par force brute (tester toutes les
  combinaisons possibles). Si vous avez un mot de passe de 5 caract�res ASCII, cela
  lui prendra au plus 5 jours. Si vous avez un mot de passe de 10 caract�res,
  cela mettra 70 milliards d'ann�es. Donc, optez pour un mot de passe d'au
  moins 6 caract�res (et eventuellement, rajoutez un caract�re sp�cial, comme
  un guillemet, pour forcer le pirate � attaquer en ASCII et non pas en
  alphanum�rique (il lui faudrait plus de temps de tester les 255 caract�res ASCII
  que seulement les 26 lettres de l'alphabet et les nombres ...)).
- Le cryptage : cela consiste � crypter le hachage par-dessus (tout en lui faisant garder
  son aspect de hachage ! Par exemple, si vous avez un hachage "A47F", n'allez
  pas le crypter en "%E#!", il appara�trait evident qu'il est crypt� !).
  Cela a pour effet de compliquer encore plus le travail du pirate, qui,
  inconsciemment, sera en train d'essayer de percer un mauvais hachage !
  Si le cryptage est bien r�alis�, il peut s'av�rer plus qu'efficace. Cependant,
  pensez � conserver la clef de cryptage/d�cryptage, sans quoi, si pour une raison
  ou pour une autre vous aviez � r�cup�rer le hash d'origine (cela peut arriver parfois),
  vous devriez tester toutes les clefs ...
  Une fonction de cryptage et une de d�cryptage est fournie dans cette unit�.
- Le byteswap : cela consiste � "swapper" les octets du hachage. Cela revient �
  crypter le hachage puisque cette op�ration est r�versible "permutative" (la
  fonction de cryptage joue �galement le r�le de la fonction de d�cryptage).

Ajouter une petite protection ne co�te rien de votre c�t�, et permet de se prot�ger
plus qu'efficacement contre des attaques. M�me si un hash en lui-m�me est d�j� pas
mal, mieux vaut trop que pas assez !

� Autres utilit�s du hash
- g�n�rateur de nombres al�atoires : l'algorithme de hachage est si particulier
pour le MD5 par exemple, qu'il a �t� d�clar� comme efficace en tant que g�n�rateur
de nombres pseudo-al�atoires, et il a pass� avec succ�s tous les tests statistiques.
L'algorithme LEA n'est pas garanti d'�tre efficace comme g�n�rateur de nombres
pseudo-al�atoires.

} *)

unit LEA_Hash;

interface

uses Windows, SysUtils, Dialogs;

const
  { Ces valeurs sont pseudo-al�atoires (voir plus bas) et sont distinctes (pas de doublon) }
  { Notez que le hachage d'une donn�e nulle (de taille 0) renverra HashTable (aucune alt�ration) }
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
   { On incr�mente chaque valeur A, B, C et D, puis on l'alt�re }
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
 { On r�cup�re les valeurs du tableau }
 Move(HashTable, Result, $10);

 { Si buffer vide, on a les valeurs initiales }
 if Size = $0 then Exit;

 { On calcule le padding }
 Cnt := $0;
 Sz := Size;
 repeat Inc(Sz) until Sz mod $40 = $0;

 { On calcule le nombre de blocs }
 BlockCount := Sz div $40;

 { On prend le d�but du buffer }
 V := @Buffer;
 { On calcule la fin du buffer }
 E := Ptr(Longword(@Buffer) + Sz);

 with Result do
  repeat { Pour chaque double mot du message, tant qu'on est pas arriv� � la fin ... }
   begin
    ZeroMemory(@Buf, $40);
    if Size - Cnt > $3F then Move(V^, Buf, $40) else
     begin
      Move(V^, Buf, Size - Cnt);
      FillMemory(Ptr(Longword(@Buf) + Succ(Size - Cnt)), 1, $80);
     end;

    { On effectue une alt�ration complexe }
    LEAInternal(A, B, C, D, Buf);

    { On appelle le callback }
    if Assigned(Callback) then Callback(Cnt div $40, BlockCount);


    Inc(V);  { On passe aux 512 bits suivants ! }
    Inc(Cnt, $40); { On incr�mente ce qui a �t� fait }
    { Ne pas modifier les lignes de calcul, sinon cela peut ne plus marcher }
   end
  until V = E;
end;

function HashStr(const Str: AnsiString): THash;
begin
 { On va envoyer le pointeur sur la cha�ne � la fonction Hash. }
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
 { On va mettre � 0 pour cette fonction, car autant il n'�tait pas possible que les fonctions
   pr�c�dentes n'�chouent, celle-ci peut �chouer pour diverses raisons. }
 ZeroMemory(@Result, 16);

 { On ouvre le fichier }
 H := CreateFile(PChar(FilePath), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE,
                 nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN, 0);

 { Si erreur d'ouverture, on s'en va }
 if H = INVALID_HANDLE_VALUE then Exit;
 { CreateFileMapping rejette les fichiers de taille 0 : ainsi, on doit les tester avant }
 if GetFileSize(H, nil) = 0 then
  begin
   Result := Hash('', 0); { On r�cup�re un hash nul }
   CloseHandle(H);        { On lib�re le handle }
   Exit;
  end;

 { On cr�e une image m�moire du fichier }
 try
  M := CreateFileMapping(H, nil, PAGE_READONLY, 0, 0, nil);
  try
   { On r�cup�re un pointeur sur l'image du fichier en m�moire }
   if M = 0 then Exit;
   P := MapViewOfFile(M, FILE_MAP_READ, 0, 0, 0);
   try
    { On envoie le pointeur au hash, avec comme taille de buffer la taille du fichier }
    if P = nil then Exit;
    Result := Hash(P^, GetFileSize(H, nil), Callback);
   finally
   { On lib�re tout ... }
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
 { On ajoute les quatre entiers l'un apr�s l'autre sous forme h�xad�cimale ... }
 Result := AnsiString(Format('%.8x%.8x%.8x%.8x', [Hash.A, Hash.B, Hash.C, Hash.D]));
end;

function StringToHash(const Str: AnsiString): THash;
begin
 if IsHash(Str) then
  with Result do
   begin
    { Astuce de Delphi : un HexToInt sans trop de probl�mes ! Rajouter un "$" devant le nombre et
     appeller StrToInt. Cette astuce accepte un maximum de 8 caract�res apr�s le signe "$".      }
    A := StrToInt(Format('$%s', [Copy(Str, 1, 8)]));
    B := StrToInt(Format('$%s', [Copy(Str, 9, 8)]));
    C := StrToInt(Format('$%s', [Copy(Str, 17, 8)]));
    D := StrToInt(Format('$%s', [Copy(Str, 25, 8)]));
   end
 else ZeroMemory(@Result, 16); { Si Str n'est pas un hash, on met tout � 0 }
end;

function SameHash(const A, B: THash): Boolean;
begin
 { On compare les deux hashs ... }
 Result := CompareMem(@A, @B, 16);
end;

function Same(A, B: Pointer; SzA, SzB: Longword): Boolean;
begin
 { Cette fonction va regarder si deux objets m�moire (d�finis par leur pointeur de d�but
   et leur taille) sont identiques en comparant leur hash. }
 Result := SameHash(Hash(A, SzA), Hash(B, SzB));
end;

const
 Z = #0; { Le caract�re nul, plus pratique de l'appeller Z que de faire chr(0) ou #0 }

function hxinc(X: AnsiChar): AnsiChar; { Incr�mentation h�xad�cimale }
const
 XInc: array [48..70] of AnsiChar = ('1', '2', '3', '4', '5', '6', '7', '8', '9', 'A',
                                      Z, Z, Z, Z, Z, Z, Z, 'B', 'C', 'D', 'E', 'F', '0');
begin
 if ord(X) in [48..57, 65..70] then Result := XInc[ord(X)] else Result := Z;
end;

function hxdec(X: AnsiChar): AnsiChar; { D�cr�mentation h�xad�cimale ... }
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
 { D�cryptage avec une clef binaire }
 Result := Hash;
 if not IsHash(Hash) then Exit;
 for I := 32 downto 1 do
  if Key and Power2[I] <> 0 then Result[I] := hxdec(Result[I]) else Result[I] := hxinc(Result[I]);
end;

function IsHash(const Hash: AnsiString): Boolean;
Var
 I: Integer;
begin
 { V�rification de la validit� de la cha�ne comme hash. }
 Result := False;
 if Length(Hash) <> 32 then Exit; { Si la taille est diff�rente de 32, c'est d�j� mort ... }
 { Si l'on rencontre un seul caract�re qui ne soit pas dans les r�gles, on s'en va ... }
 {$ifndef unicode}
 for I := 1 to 32 do if not (Hash[I] in ['0'..'9', 'A'..'F', 'a'..'f']) then Exit;
 {$else}
 for I := 1 to 32 do if not CharInSet(Hash[I], ['0'..'9', 'A'..'F', 'a'..'f']) then Exit;
 {$endif}
 { Si la chaine a pass� tous les tests, c'est bon ! }
 Result := True;
end;

end.
