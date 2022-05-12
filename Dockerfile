FROM rust:1.60

RUN apt-get update && apt-get install clang -y
COPY . .

RUN cargo build --release

CMD cargo run --release