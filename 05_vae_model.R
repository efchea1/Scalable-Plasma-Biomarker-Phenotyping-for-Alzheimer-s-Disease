library(keras)
library(tensorflow)
library(ggplot2)

load("data/final_clustered.RData")

x <- df_clust_scaled
input_dim <- ncol(x)
latent_dim <- 2
intermediate_dim <- 64

vae_model <- keras_model_custom(name = "vae", function(self) {
  
  self$encoder_input <- layer_input(shape = input_dim)
  self$enc_dense <- layer_dense(units = intermediate_dim, activation = "relu")
  self$z_mean_layer <- layer_dense(units = latent_dim)
  self$z_log_var_layer <- layer_dense(units = latent_dim)
  
  self$dec_input <- layer_input(shape = latent_dim)
  self$dec_dense <- layer_dense(units = intermediate_dim, activation = "relu")
  self$dec_output <- layer_dense(units = input_dim)
  
  encode <- function(x) {
    h <- self$enc_dense(x)
    z_mean <- self$z_mean_layer(h)
    z_log_var <- self$z_log_var_layer(h)
    epsilon <- k_random_normal(shape = k_shape(z_mean))
    z <- z_mean + k_exp(0.5 * z_log_var) * epsilon
    list(z, z_mean, z_log_var)
  }
  
  decode <- function(z) {
    h <- self$dec_dense(z)
    self$dec_output(h)
  }
  
  self$call <- function(inputs, training = FALSE) {
    res <- encode(inputs)
    z <- res[[1]]
    z_mean <- res[[2]]
    z_log_var <- res[[3]]
    reconstructed <- decode(z)
    self$z_mean <- z_mean
    self$z_log_var <- z_log_var
    reconstructed
  }
  
  self$train_step <- function(data) {
    with(tf$GradientTape() %as% tape, {
      reconstructed <- self(data, training = TRUE)
      recon_loss <- tf$reduce_mean(tf$reduce_sum(tf$math$square(data - reconstructed), axis = 1L))
      kl_loss <- -0.5 * tf$reduce_mean(tf$reduce_sum(1 + self$z_log_var - tf$math$square(self$z_mean) - tf$math$exp(self$z_log_var), axis = 1L))
      total_loss <- recon_loss + kl_loss
    })
    gradients <- tape$gradient(total_loss, self$trainable_variables)
    self$optimizer$apply_gradients(purrr::transpose(list(gradients, self$trainable_variables)))
    list(loss = total_loss)
  }
  
  self$encoder <- keras_model(self$encoder_input,
                              list(self$z_mean_layer(self$enc_dense(self$encoder_input)),
                                   self$z_log_var_layer(self$enc_dense(self$encoder_input))))
  
  self$decoder <- keras_model(self$dec_input,
                              self$dec_output(self$dec_dense(self$dec_input)))
})

vae_model %>% compile(optimizer = "adam")

history <- vae_model %>% fit(
  x,
  epochs = 50,
  batch_size = 32,
  verbose = 1
)

vae_model$encoder %>% save_model_hdf5("models/encoder_model.h5")
vae_model$decoder %>% save_model_hdf5("models/decoder_model.h5")

encoded_means <- predict(vae_model$encoder, x)[[1]]
latent <- data.frame(z1 = encoded_means[,1], z2 = encoded_means[,2])
latent$ATN <- final$ATN[match(rownames(df_clust), final$HHID_PN)]

ggplot(latent, aes(z1, z2, color = ATN)) +
  geom_point(alpha = 0.6) +
  theme_minimal()

save(latent, file = "results/vae_latent.RData")
