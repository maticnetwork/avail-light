FROM rust:1.60

COPY . .

RUN apt-get update && apt-get install clang -y
RUN cargo build --release

CMD cargo run --release