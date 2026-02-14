package main

import (
	"context"
	"fmt"
	"html/template"
	"log"
	"math/rand"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"
)

var adjectives = []string{
	"electric", "cosmic", "velvet", "neon", "phantom",
	"crimson", "silent", "iron", "golden", "savage",
	"atomic", "lunar", "crystal", "shadow", "wicked",
	"hollow", "frozen", "rogue", "mystic", "sterling",
}

var nouns = []string{
	"wolves", "thunder", "echoes", "horizon", "paradox",
	"ravens", "serpents", "voltage", "cathedral", "static",
	"ember", "abyss", "zenith", "mirage", "phoenix",
	"spectra", "void", "tempest", "orchid", "mercury",
}

func randomFrom(words []string) string {
	return words[rand.Intn(len(words))]
}

func capitalize(s string) string {
	if len(s) == 0 {
		return s
	}
	return strings.ToUpper(s[:1]) + s[1:]
}

func generateBandName() string {
	patterns := []func() string{
		// the + adjective + noun
		func() string {
			return fmt.Sprintf("The %s %s", capitalize(randomFrom(adjectives)), capitalize(randomFrom(nouns)))
		},
		// adjective + noun
		func() string {
			return fmt.Sprintf("%s %s", capitalize(randomFrom(adjectives)), capitalize(randomFrom(nouns)))
		},
		// noun + of + noun
		func() string {
			return fmt.Sprintf("%s of %s", capitalize(randomFrom(nouns)), capitalize(randomFrom(nouns)))
		},
		// the + noun
		func() string {
			return fmt.Sprintf("The %s", capitalize(randomFrom(nouns)))
		},
	}
	return patterns[rand.Intn(len(patterns))]()
}

func main() {
	tmpl := template.Must(template.ParseFiles("templates/index.html"))

	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		data := map[string]string{
			"BandName": generateBandName(),
		}
		if err := tmpl.Execute(w, data); err != nil {
			http.Error(w, "internal server error", http.StatusInternalServerError)
			log.Printf("template error: %v", err)
		}
	})

	srv := &http.Server{
		Addr:    ":8080",
		Handler: mux,
	}

	// graceful shutdown
	go func() {
		sigChan := make(chan os.Signal, 1)
		signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)
		<-sigChan
		log.Println("shutting down")
		srv.Shutdown(context.Background())
	}()

	log.Println("running on http://0.0.0.0:8080")
	if err := srv.ListenAndServe(); err != http.ErrServerClosed {
		log.Fatal(err)
	}
}
