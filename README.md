# flutter_messenger

Flutter messenger with Firebase Auth + Firestore private 1-on-1 chats.

## Firestore data model

- `users/{userId}`: profile docs used by `UsersListScreen`
- `chats/{chatId}/messages/{messageId}`: private messages
- `chatId` format: two UIDs sorted and joined with `_` (example: `uidA_uidB`)

## Firestore rules (concept)

Use rules that only allow participants to access their chat:

```txt
match /chats/{chatId}/messages/{messageId} {
  allow read, write: if request.auth != null
    && chatId.split('_').hasAny([request.auth.uid]);
}
```
