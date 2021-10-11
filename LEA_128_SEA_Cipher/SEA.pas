{ Algorithme d'encryptage/décryptage SEA (Stream Encoding Algorithm) }
{ Auteur : Bacterius (www.delphifr.com) }
{ Copyright : NE PAS MODIFIER CE FICHIER SANS ACCORD DE L'AUTEUR/
              DO NOT MODIFY THIS FILE WITHOUT AUTHOR PERMISSION  }

unit SEA;

interface

uses Windows, LEA_Hash;

type
 { Le type du callback : octet n°Position sur Count }
 { Pour éviter de massacrer le temps d'execution du code, veillez à ne traiter qu'un certain nombre
   de callbacks (tous les 2^16 octets par exemple) }
 TSEACallback = procedure (Position, Count: Longword);
 { Oui, c'est toujours plus lisible et ça change rien }
 TSEAKey = THash;

const
 OPERATION_ENCRYPT = $1; { Pour encrypter }
 OPERATION_DECRYPT = $2; { Pour décrypter }
 OPERATION_FAST    = $4; { Encryptage/Décryptage rapide }
 OPERATION_SECURE  = $8; { Encryptage/Décryptage très lent mais plus sécurisé }

function ObtainKey(Str: String): TSEAKey;
function Encrypt(var Buffer; const Size: Longword; Key: TSEAKey; const Operation: Longword; Callback: TSEACallback = nil): Boolean;
function EncryptFile(const FilePath: String; const Key: TSEAKey; const Operation: Longword; Callback: TSEACallback = nil): Boolean;

implementation


{ Les fonctions de rotate-shift left (ROL) et right (ROR) sur des octets et sur double-mots }
function RShlLong(A, B: Longword): Longword;
begin
 Result := (A shl B) or (A shr ($08 - B));
end;

function RShl(A, B: Byte): Byte;
begin
 Result := (A shl B) or (A shr ($08 - B));
end;

function RShr(A, B: Byte): Byte;
begin
 Result := (A shr B) or (A shl ($08 - B));
end;

{ Fonction pour obtenir une clef d'encryptage 128 bits à partir d'une chaîne }
function ObtainKey(Str: String): TSEAKey;
begin
 Result := HashStr(Str);
end;

{ La fonction d'encryptage : le Buffer sert d'entrée de données et de sortie de données }
function Encrypt(var Buffer; const Size: Longword; Key: TSEAKey; const Operation: Longword; Callback: TSEACallback = nil): Boolean;
Var
 P, E: PByte;
 I: Longword;
 H: THash;
begin
 Result := False;

 { Encrypter ou décrypter, il faut choisir ! }
 if (OPERATION_ENCRYPT and Operation <> 0) and (OPERATION_DECRYPT and Operation <> 0) then Exit;
 if (OPERATION_ENCRYPT and Operation = 0) and (OPERATION_DECRYPT and Operation = 0) then Exit;

 { Idem pour le niveau de sécurité }
 if (OPERATION_FAST and Operation <> 0) and (OPERATION_SECURE and Operation <> 0) then Exit;
 if (OPERATION_FAST and Operation = 0) and (OPERATION_SECURE and Operation = 0) then Exit;

 { On refuse les données de taille 0 (après tout, ça ne changerait rien) }
 if Size = 0 then Exit;

 { On définit le début et la fin du buffer, et on met le compteur (I) à 0 }
 P := @Buffer;
 E := Ptr(Longword(@Buffer) + Size);
 I := 0;

 { On prend un hash initial }
 H := Hash(I, 4, nil);

 repeat
  { Si on est en décryptage, on effectue un rotate-shift RIGHT sur la clef au DEBUT }
  if (OPERATION_DECRYPT and Operation <> 0) then P^ := RShr(P^, (Key.B mod $08) xor (I mod $08));

  { De temps en temps on modifie le hashage de la position actuelle selon le niveau de sécurité }
  if (Operation and OPERATION_SECURE <> 0) then H := Hash(I, 4, nil);
  if (Operation and OPERATION_FAST <> 0) then if Succ(I) mod $FF = 0 then H := Hash(I, 4, nil);

  { Rien de très compliqué, des opérations réversibles pourvu qu'on ait la clef :D }
  with H do
   begin
    P^ := (Key.B mod $FF) xor (P^ xor (C mod $FF));
    P^ := (Key.A mod $FF) xor (P^ xor (B mod $FF));
    P^ := (Key.D mod $FF) xor (P^ xor (A mod $FF));
    P^ := (Key.C mod $FF) xor (P^ xor (D mod $FF));
   end;

  { Si on est en encryptage, on effectue un rotate-shift LEFT sur la clef à la FIN }
  if (OPERATION_ENCRYPT and Operation <> 0) then P^ := RShl(P^, (Key.B mod $08) xor (I mod $08));

  { On envoie le callback si l'application en a fourni un }
  if Assigned(Callback) then Callback(Succ(I), Size);

  { On avance dans le buffer, et on incrémente le compteur }
  Inc(P);
  Inc(I);
 until P = E;

 Result := True;
end;

function EncryptFile(const FilePath: String; const Key: TSEAKey; const Operation: Longword; Callback: TSEACallback = nil): Boolean;
Var
 H, M: Longword;
 P: Pointer;
begin
 Result := False;

 { On ouvre le fichier avec droits exclusifs }
 H := CreateFile(PChar(FilePath), GENERIC_READ or GENERIC_WRITE, 0,
                 nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN, 0);

 if H = INVALID_HANDLE_VALUE then Exit;

 { CreateFileMapping rejette les fichiers de taille 0. Notre fonction d'encryptage/décryptage les
   rejette également. Alors autant arrêter là plutôt que de bousiller des cycles inutiles. }
 if GetFileSize(H, nil) = 0 then
  begin
   CloseHandle(H);
   Exit;
  end;

 try
  { On crée une image du fichier en mémoire (lecture/écriture) }
  M := CreateFileMapping(H, nil, PAGE_READWRITE, 0, 0, nil);
  try
   if M = 0 then Exit;
   { On mappe le fichier en mémoire en lecture/écriture }
   P := MapViewOfFile(M, FILE_MAP_READ or FILE_MAP_WRITE, 0, 0, 0);
   try
    if P = nil then Exit;
    { Et on envoie le pointeur sur le fichier à la fonction. Attention, le fichier crypté/décrypté
      remplace l'original ! }
    Result := Encrypt(P^, GetFileSize(H, nil), Key, Operation, Callback);
   finally
   { On fait le ménage derrière nous ... }
   UnmapViewOfFile(P);
   end;
  finally
   CloseHandle(M);
  end;
 finally
  CloseHandle(H);
 end;
end;

end.
