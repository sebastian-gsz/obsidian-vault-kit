# Referencia de embeds

## Embed de notas

```markdown
![[Note Name]]
![[Note Name#Heading]]
![[Note Name#^block-id]]
```

## Embed de imágenes

```markdown
![[image.png]]
![[image.png|640x480]]    Width x Height
![[image.png|300]]        Width only (maintains aspect ratio)
```

## Imágenes externas

```markdown
![Alt text](https://example.com/image.png)
![Alt text|300](https://example.com/image.png)
```

## Embed de audio

```markdown
![[audio.mp3]]
![[audio.ogg]]
```

## Embed de PDF

```markdown
![[document.pdf]]
![[document.pdf#page=3]]
![[document.pdf#height=400]]
```

## Embed de bases

```markdown
![[BaseFile.base]]
![[BaseFile.base#View Name]]
```

## Embed de listas

```markdown
![[Note#^list-id]]
```

Donde la lista tiene un block ID:

```markdown
- Item 1
- Item 2
- Item 3

^list-id
```

## Embed de resultados de búsqueda

````markdown
```query
tag:#project status:done
```
````
